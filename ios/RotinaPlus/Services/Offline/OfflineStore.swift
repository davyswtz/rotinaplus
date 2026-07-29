import Foundation

enum OfflineCacheKey: String {
    case dashboard
    case academia
    case financas
    case amigos
    case notificacoes
    case historicoTreinos
    case classes

    static func habitos(data: String?) -> String {
        if let data, !data.isEmpty { return "habitos_\(data)" }
        return "habitos_hoje"
    }

    static func perfilStats(periodo: String) -> String {
        "perfil_stats_\(periodo)"
    }

    static func amigoStats(id: Int, periodo: String) -> String {
        "amigo_stats_\(id)_\(periodo)"
    }

    static func treino(id: Int) -> String {
        "treino_\(id)"
    }

    static func catalogo(grupo: String?) -> String {
        "catalogo_\(grupo ?? "all")"
    }

    static func financas(mes: String?) -> String {
        if let mes, !mes.isEmpty { return "financas_\(mes)" }
        return OfflineCacheKey.financas.rawValue
    }
}

enum OfflineMutationKind: String, Codable {
    case toggleMissao
    case criarMissao
    case toggleHabitoCheckin
    case criarHabito
    case atualizarHabitoNota
    case excluirHabito
    case toggleAcademiaDia
    case registrarEsporte
    case excluirEsporteSessao
    case criarTreino
    case toggleTreinoExercicio
    case concluirTreino
    case criarTransacao
    case excluirTransacao
    case criarMeta
    case atualizarMeta
    case atualizarPerfil
}

struct OfflineMutation: Codable, Identifiable, Equatable {
    var id: UUID
    var kind: OfflineMutationKind
    var payloadJSON: Data
    var createdAt: Date

    init(kind: OfflineMutationKind, payload: some Encodable) throws {
        self.id = UUID()
        self.kind = kind
        self.createdAt = Date()
        self.payloadJSON = try JSONEncoder().encode(payload)
    }

    func decodePayload<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: payloadJSON)
    }
}

/// Persistência local: snapshots das telas + fila de mutações.
final class OfflineStore {
    static let shared = OfflineStore()

    private let defaults = UserDefaults.standard
    private let cachePrefix = "offline_cache_"
    private let outboxKey = "offline_outbox_v1"
    private let lock = NSLock()

    private init() {}

    func save<T: Encodable>(_ value: T, key: String) {
        lock.lock()
        defer { lock.unlock() }
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: cachePrefix + key)
        } catch {
            // Ignora falha de encode; app segue online.
        }
    }

    func save<T: Encodable>(_ value: T, key: OfflineCacheKey) {
        save(value, key: key.rawValue)
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        lock.lock()
        defer { lock.unlock() }
        guard let data = defaults.data(forKey: cachePrefix + key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func load<T: Decodable>(_ type: T.Type, key: OfflineCacheKey) -> T? {
        load(type, key: key.rawValue)
    }

    func enqueue(_ mutation: OfflineMutation) {
        lock.lock()
        defer { lock.unlock() }
        var list = loadOutboxUnlocked()
        list.append(mutation)
        saveOutboxUnlocked(list)
    }

    func allMutations() -> [OfflineMutation] {
        lock.lock()
        defer { lock.unlock() }
        return loadOutboxUnlocked()
    }

    func pendingCount() -> Int {
        allMutations().count
    }

    func removeMutation(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        var list = loadOutboxUnlocked()
        list.removeAll { $0.id == id }
        saveOutboxUnlocked(list)
    }

    func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(cachePrefix) }
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.removeObject(forKey: outboxKey)
    }

    private func loadOutboxUnlocked() -> [OfflineMutation] {
        guard let data = defaults.data(forKey: outboxKey) else { return [] }
        return (try? JSONDecoder().decode([OfflineMutation].self, from: data)) ?? []
    }

    private func saveOutboxUnlocked(_ list: [OfflineMutation]) {
        if let data = try? JSONEncoder().encode(list) {
            defaults.set(data, forKey: outboxKey)
        }
    }
}
