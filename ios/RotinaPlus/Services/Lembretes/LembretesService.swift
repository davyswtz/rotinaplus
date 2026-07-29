import Foundation
import UserNotifications

/// Lembretes locais de missões e hábitos (não depende de push remoto).
@MainActor
final class LembretesService: NSObject, ObservableObject {
    static let shared = LembretesService()

    private static let ativosKey = "lembretes_ativos"
    private static let horaManhaKey = "lembretes_hora_manha"
    private static let horaNoiteKey = "lembretes_hora_noite"
    private static let pediuPermissaoKey = "lembretes_pediu_permissao"

    private let centro = UNUserNotificationCenter.current()
    private let prefixo = "rotinaplus.lembrete."

    @Published private(set) var autorizacao: UNAuthorizationStatus = .notDetermined

    /// Preferência do usuário (default: ligado).
    var ativos: Bool {
        get {
            if UserDefaults.standard.object(forKey: Self.ativosKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: Self.ativosKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.ativosKey)
            Task { await reagendarTudo() }
        }
    }

    /// Hora do lembrete da manhã (0–23). Default 9.
    var horaManha: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: Self.horaManhaKey)
            return (0...23).contains(v) && UserDefaults.standard.object(forKey: Self.horaManhaKey) != nil ? v : 9
        }
        set {
            UserDefaults.standard.set(min(23, max(0, newValue)), forKey: Self.horaManhaKey)
            Task { await reagendarTudo() }
        }
    }

    /// Hora do lembrete da noite. Default 20.
    var horaNoite: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: Self.horaNoiteKey)
            return (0...23).contains(v) && UserDefaults.standard.object(forKey: Self.horaNoiteKey) != nil ? v : 20
        }
        set {
            UserDefaults.standard.set(min(23, max(0, newValue)), forKey: Self.horaNoiteKey)
            Task { await reagendarTudo() }
        }
    }

    private override init() {
        super.init()
    }

    func configurar() {
        centro.delegate = self
        Task { await atualizarStatusAutorizacao() }
    }

    func atualizarStatusAutorizacao() async {
        let settings = await centro.notificationSettings()
        autorizacao = settings.authorizationStatus
    }

    @discardableResult
    func pedirPermissaoSeNecessario() async -> Bool {
        await atualizarStatusAutorizacao()
        switch autorizacao {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let ok = try await centro.requestAuthorization(options: [.alert, .sound, .badge])
                UserDefaults.standard.set(true, forKey: Self.pediuPermissaoKey)
                await atualizarStatusAutorizacao()
                return ok
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    /// Reagenda lembretes com base no cache local (offline-friendly).
    func reagendarTudo() async {
        await cancelarAgendados()

        guard ativos else { return }
        let permitido = await pedirPermissaoSeNecessario()
        guard permitido else { return }

        let dash = OfflineStore.shared.load(DashboardAPI.self, key: .dashboard)
        let missoesPendentes = dash?.missoes.filter { !$0.concluida }.count ?? 0
        let habitos = OfflineStore.shared.load(HabitoJournalAPI.self, key: OfflineCacheKey.habitos(data: nil))
        let habitosPendentes = habitos?.itens.filter { !$0.concluida }.count
            ?? dash?.habitosResumo.map { max(0, $0.total - $0.concluidos) }
            ?? 0

        let totalPendentes = missoesPendentes + habitosPendentes

        await agendar(
            id: "manha",
            hora: horaManha,
            titulo: "🦊 Missões do dia",
            corpo: totalPendentes > 0
                ? "Você tem desafios te esperando. Bora completar a rotina!"
                : "Novo dia, novas missões. Abra o Rotina Plus e comece!"
        )

        await agendar(
            id: "noite",
            hora: horaNoite,
            titulo: "🔥 Ainda dá tempo",
            corpo: totalPendentes > 0
                ? "Faltam \(totalPendentes) desafio(s) hoje. Finalize antes de dormir!"
                : "Dia limpo! Que tal revisar amanhã e manter a sequência?"
        )

        // Lembrete individual para hábitos ativos (até 8 para não spammar).
        if let itens = habitos?.itens {
            for item in itens.prefix(8) where (item.habito.ativo ?? true) {
                let titulo = "\(item.habito.icone) \(item.habito.titulo)"
                let corpo = item.concluida
                    ? "Já feito hoje — amanhã de novo!"
                    : (item.habito.detalhe?.isEmpty == false
                        ? item.habito.detalhe!
                        : "Hora do seu hábito. Marque no diário!")
                await agendar(
                    id: "habito.\(item.habito.id)",
                    hora: horaManha,
                    minuto: 30,
                    titulo: titulo,
                    corpo: corpo,
                    weekday: weekdayComponents(for: item.habito)
                )
            }
        }
    }

    private func weekdayComponents(for habito: HabitoAPI) -> [Int]? {
        guard habito.frequencia == "semanal",
              let dias = habito.diasSemana, !dias.isEmpty else {
            return nil // diário
        }
        // Backend: 1=seg … 7=dom. iOS: 1=dom … 7=sáb.
        return dias.map { backend in
            backend == 7 ? 1 : backend + 1
        }
    }

    private func agendar(
        id: String,
        hora: Int,
        minuto: Int = 0,
        titulo: String,
        corpo: String,
        weekday: [Int]? = nil
    ) async {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = titulo
        conteudo.body = corpo
        conteudo.sound = .default
        conteudo.categoryIdentifier = "LEMBRETE_ROTINA"

        if let weekdays = weekday, !weekdays.isEmpty {
            for day in weekdays {
                var comps = DateComponents()
                comps.hour = hora
                comps.minute = minuto
                comps.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(prefixo)\(id).d\(day)",
                    content: conteudo,
                    trigger: trigger
                )
                try? await centro.add(request)
            }
        } else {
            var comps = DateComponents()
            comps.hour = hora
            comps.minute = minuto
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(prefixo)\(id)",
                content: conteudo,
                trigger: trigger
            )
            try? await centro.add(request)
        }
    }

    private func cancelarAgendados() async {
        let pendentes = await centro.pendingNotificationRequests()
        let ids = pendentes.map(\.identifier).filter { $0.hasPrefix(prefixo) }
        centro.removePendingNotificationRequests(withIdentifiers: ids)
    }
}

extension LembretesService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
