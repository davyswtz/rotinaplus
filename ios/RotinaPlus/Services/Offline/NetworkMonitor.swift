import Foundation
import Network

/// Monitora conectividade para flush da fila offline.
@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isOnline: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "rotinaplus.network")
    private var started = false

    private init() {}

    func start() {
        guard !started else { return }
        started = true
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                let online = path.status == .satisfied
                let wasOffline = !(self?.isOnline ?? true)
                self?.isOnline = online
                if online && wasOffline {
                    await OfflineSyncEngine.shared.flush()
                }
            }
        }
        monitor.start(queue: queue)
    }

    /// Chamado quando uma request remota falha por rede/servidor.
    func markOffline() {
        isOnline = false
    }

    /// Chamado quando uma request remota conclui com sucesso.
    func markOnline() {
        let wasOffline = !isOnline
        isOnline = true
        if wasOffline {
            Task { await OfflineSyncEngine.shared.flush() }
        }
    }
}
