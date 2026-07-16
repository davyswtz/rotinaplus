import Foundation

/// Camada de API do app (dashboard, missões, academia, notificações).
enum RotinaPlusAPI {
    static func dashboard() async throws -> DashboardAPI {
        let response: APIResponse<DashboardAPI> = try await APIClient.shared.request(
            endpoint: .dashboard,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func toggleMissao(id: Int) async throws -> MissaoAPI {
        let response: APIResponse<MissaoAPI> = try await APIClient.shared.request(
            endpoint: .toggleMissao(id: id),
            method: .patch,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func notificacoes() async throws -> [NotificacaoAPI] {
        let response: APIResponse<[NotificacaoAPI]> = try await APIClient.shared.request(
            endpoint: .notificacoes,
            requiresAuth: true
        )
        return response.data ?? []
    }

    static func marcarNotificacaoLida(id: Int) async throws {
        let _: APIResponse<NotificacaoAPI> = try await APIClient.shared.request(
            endpoint: .marcarNotificacaoLida(id: id),
            method: .patch,
            requiresAuth: true
        )
    }

    static func lerTodasNotificacoes() async throws {
        struct Payload: Decodable {
            let atualizadas: Int?
        }
        let _: APIResponse<Payload> = try await APIClient.shared.request(
            endpoint: .lerTodasNotificacoes,
            method: .post,
            requiresAuth: true
        )
    }

    static func academia() async throws -> AcademiaAPI {
        let response: APIResponse<AcademiaAPI> = try await APIClient.shared.request(
            endpoint: .academia,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func toggleAcademiaDia(id: Int) async throws {
        struct DiaToggle: Decodable {
            let id: Int
            let concluido: Bool
        }
        let _: APIResponse<DiaToggle> = try await APIClient.shared.request(
            endpoint: .toggleAcademiaDia(id: id),
            method: .patch,
            requiresAuth: true
        )
    }
}
