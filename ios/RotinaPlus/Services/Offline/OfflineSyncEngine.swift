import Foundation

/// Gateway: lê cache se a rede falhar; writes são local-first + fila de sync.
enum OfflineGateway {
    static func cachedFetch<T: Codable>(
        key: String,
        remote: () async throws -> T
    ) async throws -> T {
        do {
            let value = try await remote()
            OfflineStore.shared.save(value, key: key)
            await MainActor.run { NetworkMonitor.shared.markOnline() }
            return value
        } catch {
            if let cached = OfflineStore.shared.load(T.self, key: key) {
                if shouldTreatAsOffline(error) {
                    await MainActor.run { NetworkMonitor.shared.markOffline() }
                }
                return cached
            }
            throw error
        }
    }

    static func cachedFetch<T: Codable>(
        key: OfflineCacheKey,
        remote: () async throws -> T
    ) async throws -> T {
        try await cachedFetch(key: key.rawValue, remote: remote)
    }

    /// Local-first: se o remoto falhar (rede/servidor), enfileira e devolve o valor local.
    /// Só propaga erro de auth (401/403) ou validação do cliente (400/422).
    static func mutate<T>(
        kind: OfflineMutationKind,
        payload: some Encodable,
        offlineValue: T,
        remote: () async throws -> T
    ) async throws -> T {
        let online = await MainActor.run { NetworkMonitor.shared.isOnline }

        if online {
            do {
                let value = try await remote()
                await MainActor.run { NetworkMonitor.shared.markOnline() }
                return value
            } catch let error as APIError where error.isUnauthorized {
                throw error
            } catch let error as APIError where error.isValidationError {
                throw error
            } catch {
                await MainActor.run { NetworkMonitor.shared.markOffline() }
                try enqueue(kind: kind, payload: payload)
                return offlineValue
            }
        }

        try enqueue(kind: kind, payload: payload)
        return offlineValue
    }

    /// Variante sem valor de retorno (Void).
    static func mutate(
        kind: OfflineMutationKind,
        payload: some Encodable,
        remote: () async throws -> Void
    ) async throws {
        let _: Bool = try await mutate(
            kind: kind,
            payload: payload,
            offlineValue: true,
            remote: {
                try await remote()
                return true
            }
        )
    }

    static func enqueue(kind: OfflineMutationKind, payload: some Encodable) throws {
        let mutation = try OfflineMutation(kind: kind, payload: payload)
        OfflineStore.shared.enqueue(mutation)
        Task { @MainActor in
            await OfflineSyncEngine.shared.flush()
        }
    }

    private static func shouldTreatAsOffline(_ error: Error) -> Bool {
        if let api = error as? APIError {
            if api.isUnauthorized || api.isValidationError { return false }
            return true
        }
        if error is URLError { return true }
        let ns = error as NSError
        return ns.domain == NSURLErrorDomain
    }
}

/// Reenvia mutações pendentes quando há internet.
@MainActor
final class OfflineSyncEngine {
    static let shared = OfflineSyncEngine()

    private var flushing = false

    private init() {}

    func start() {
        NetworkMonitor.shared.start()
        Task { await flush() }
    }

    func flush() async {
        guard !flushing else { return }
        guard NetworkMonitor.shared.isOnline else { return }
        guard AuthManager.shared.token != nil else { return }

        flushing = true
        defer { flushing = false }

        let pending = OfflineStore.shared.allMutations()
        for mutation in pending {
            do {
                try await replay(mutation)
                OfflineStore.shared.removeMutation(id: mutation.id)
            } catch let error as APIError where error.isUnauthorized {
                break
            } catch {
                // Mantém na fila para próxima tentativa.
                break
            }
        }
    }

    private func replay(_ mutation: OfflineMutation) async throws {
        switch mutation.kind {
        case .toggleMissao:
            let p = try mutation.decodePayload(ToggleMissaoPayload.self)
            _ = try await RotinaPlusAPI.remoteToggleMissao(id: p.id, concluida: p.concluida)

        case .criarMissao:
            let p = try mutation.decodePayload(CriarMissaoPayload.self)
            _ = try await RotinaPlusAPI.remoteCriarMissao(
                titulo: p.titulo,
                detalhe: p.detalhe,
                icone: p.icone,
                clientUUID: p.clientUUID
            )

        case .toggleHabitoCheckin:
            let p = try mutation.decodePayload(ToggleHabitoPayload.self)
            _ = try await RotinaPlusAPI.remoteToggleHabitoCheckin(
                id: p.id,
                data: p.data,
                humor: p.humor,
                nota: p.nota,
                concluida: p.concluida
            )

        case .criarHabito:
            let p = try mutation.decodePayload(CriarHabitoPayload.self)
            _ = try await RotinaPlusAPI.remoteCriarHabito(
                titulo: p.titulo,
                detalhe: p.detalhe,
                icone: p.icone,
                area: p.area,
                clientUUID: p.clientUUID
            )

        case .atualizarHabitoNota:
            let p = try mutation.decodePayload(HabitoNotaPayload.self)
            _ = try await RotinaPlusAPI.remoteAtualizarHabitoNota(
                id: p.id,
                data: p.data,
                nota: p.nota,
                humor: p.humor
            )

        case .excluirHabito:
            let p = try mutation.decodePayload(IdPayload.self)
            try await RotinaPlusAPI.remoteExcluirHabito(id: p.id)

        case .toggleAcademiaDia:
            let p = try mutation.decodePayload(ToggleAcademiaDiaPayload.self)
            try await RotinaPlusAPI.remoteToggleAcademiaDia(id: p.id, concluido: p.concluido)

        case .registrarEsporte:
            let p = try mutation.decodePayload(RegistrarEsportePayload.self)
            _ = try await RotinaPlusAPI.remoteRegistrarEsporte(
                chave: p.chave,
                minutos: p.minutos,
                distanciaMetros: p.distanciaMetros,
                nota: p.nota,
                clientUUID: p.clientUUID
            )

        case .excluirEsporteSessao:
            let p = try mutation.decodePayload(IdPayload.self)
            try await RotinaPlusAPI.remoteExcluirEsporteSessao(id: p.id)

        case .criarTreino:
            let p = try mutation.decodePayload(CriarTreinoPayload.self)
            _ = try await RotinaPlusAPI.remoteCriarTreino(
                foco: p.foco,
                titulo: p.titulo,
                minutos: p.minutos,
                exercicios: p.exercicios,
                clientUUID: p.clientUUID
            )

        case .toggleTreinoExercicio:
            let p = try mutation.decodePayload(ToggleTreinoExercicioPayload.self)
            try await RotinaPlusAPI.remoteToggleTreinoExercicio(
                treinoId: p.treinoId,
                exercicioId: p.exercicioId,
                concluido: p.concluido
            )

        case .concluirTreino:
            let p = try mutation.decodePayload(IdPayload.self)
            _ = try await RotinaPlusAPI.remoteConcluirTreino(id: p.id)

        case .criarTransacao:
            let p = try mutation.decodePayload(CriarTransacaoPayload.self)
            _ = try await RotinaPlusAPI.remoteCriarTransacao(p)

        case .excluirTransacao:
            let p = try mutation.decodePayload(IdPayload.self)
            try await RotinaPlusAPI.remoteExcluirTransacao(id: p.id)

        case .criarMeta:
            let p = try mutation.decodePayload(CriarMetaPayload.self)
            _ = try await RotinaPlusAPI.remoteCriarMeta(p)

        case .atualizarMeta:
            let p = try mutation.decodePayload(AtualizarMetaPayload.self)
            _ = try await RotinaPlusAPI.remoteAtualizarMeta(p)

        case .atualizarPerfil:
            let p = try mutation.decodePayload(AtualizarPerfilPayload.self)
            _ = try await RotinaPlusAPI.remoteAtualizarPerfilCampos(
                nomeHeroi: p.nomeHeroi,
                avatarKey: p.avatarKey,
                classe: p.classe,
                emojiClasse: p.emojiClasse
            )
        }
    }
}

// MARK: - Payloads da fila

struct IdPayload: Codable {
    var id: Int
}

struct ToggleMissaoPayload: Codable {
    var id: Int
    var concluida: Bool
}

struct CriarMissaoPayload: Codable {
    var titulo: String
    var detalhe: String?
    var icone: String
    var clientUUID: String
}

struct ToggleHabitoPayload: Codable {
    var id: Int
    var data: String?
    var humor: Int?
    var nota: String?
    var concluida: Bool
}

struct CriarHabitoPayload: Codable {
    var titulo: String
    var detalhe: String?
    var icone: String
    var area: String
    var clientUUID: String
}

struct HabitoNotaPayload: Codable {
    var id: Int
    var data: String?
    var nota: String?
    var humor: Int?
}

struct ToggleAcademiaDiaPayload: Codable {
    var id: Int
    var concluido: Bool
}

struct RegistrarEsportePayload: Codable {
    var chave: String
    var minutos: Int
    var distanciaMetros: Int?
    var nota: String?
    var clientUUID: String
}

struct CriarTreinoPayload: Codable {
    var foco: String
    var titulo: String?
    var minutos: Int
    var exercicios: [TreinoExercicioPayload]
    var clientUUID: String
}

struct ToggleTreinoExercicioPayload: Codable {
    var treinoId: Int
    var exercicioId: Int
    var concluido: Bool
}

struct CriarTransacaoPayload: Codable {
    var tipo: String
    var categoria: String
    var titulo: String
    var icone: String?
    var valorCentavos: Int
    var data: String?
    var clientUUID: String

    enum CodingKeys: String, CodingKey {
        case tipo, categoria, titulo, icone, data
        case valorCentavos = "valor_centavos"
        case clientUUID = "client_uuid"
    }
}

struct CriarMetaPayload: Codable {
    var titulo: String
    var icone: String?
    var valorAlvoCentavos: Int
    var clientUUID: String

    enum CodingKeys: String, CodingKey {
        case titulo, icone
        case valorAlvoCentavos = "valor_alvo_centavos"
        case clientUUID = "client_uuid"
    }
}

struct AtualizarMetaPayload: Codable {
    var id: Int
    var titulo: String?
    var valorAlvoCentavos: Int?
    var valorAtualCentavos: Int?

    enum CodingKeys: String, CodingKey {
        case id, titulo
        case valorAlvoCentavos = "valor_alvo_centavos"
        case valorAtualCentavos = "valor_atual_centavos"
    }
}

struct AtualizarPerfilPayload: Codable {
    var nomeHeroi: String?
    var avatarKey: String?
    var classe: String?
    var emojiClasse: String?
}
