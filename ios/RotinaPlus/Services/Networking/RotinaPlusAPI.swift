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

    static func updatePerfil(
        nomeHeroi: String,
        avatarKey: String,
        classe: String,
        emojiClasse: String
    ) async throws -> PerfilAPI {
        struct Body: Encodable {
            let nomeHeroi: String
            let avatarKey: String
            let classe: String
            let emojiClasse: String

            enum CodingKeys: String, CodingKey {
                case nomeHeroi = "nome_heroi"
                case avatarKey = "avatar_key"
                case classe
                case emojiClasse = "emoji_classe"
            }
        }

        let response: APIResponse<PerfilAPI> = try await APIClient.shared.request(
            endpoint: .perfil,
            method: .put,
            body: Body(
                nomeHeroi: nomeHeroi,
                avatarKey: avatarKey,
                classe: classe,
                emojiClasse: emojiClasse
            ),
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

    static func criarMissao(
        titulo: String,
        detalhe: String?,
        icone: String
    ) async throws -> MissaoAPI {
        struct Body: Encodable {
            let titulo: String
            let detalhe: String?
            let icone: String
        }

        let response: APIResponse<MissaoAPI> = try await APIClient.shared.request(
            endpoint: .missoes,
            method: .post,
            body: Body(titulo: titulo, detalhe: detalhe, icone: icone),
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

    static func financas(mes: String? = nil) async throws -> FinancasAPI {
        let response: APIResponse<FinancasAPI> = try await APIClient.shared.request(
            endpoint: .financas(mes: mes),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func criarTransacao(
        tipo: String,
        categoria: String,
        titulo: String,
        icone: String?,
        valorCentavos: Int,
        data: String
    ) async throws -> FinancasTransacaoAPI {
        struct Body: Encodable {
            let tipo: String
            let categoria: String
            let titulo: String
            let icone: String?
            let valorCentavos: Int
            let data: String

            enum CodingKeys: String, CodingKey {
                case tipo, categoria, titulo, icone, data
                case valorCentavos = "valor_centavos"
            }
        }

        let response: APIResponse<FinancasTransacaoAPI> = try await APIClient.shared.request(
            endpoint: .financasTransacoes,
            method: .post,
            body: Body(
                tipo: tipo,
                categoria: categoria,
                titulo: titulo,
                icone: icone,
                valorCentavos: valorCentavos,
                data: data
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func excluirTransacao(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .financasTransacao(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    static func criarMeta(
        titulo: String,
        icone: String?,
        valorAlvoCentavos: Int
    ) async throws -> FinancasMetaAPI {
        struct Body: Encodable {
            let titulo: String
            let icone: String?
            let valorAlvoCentavos: Int

            enum CodingKeys: String, CodingKey {
                case titulo, icone
                case valorAlvoCentavos = "valor_alvo_centavos"
            }
        }

        let response: APIResponse<FinancasMetaAPI> = try await APIClient.shared.request(
            endpoint: .financasMetas,
            method: .post,
            body: Body(titulo: titulo, icone: icone, valorAlvoCentavos: valorAlvoCentavos),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func atualizarMeta(id: Int, valorAtualCentavos: Int) async throws -> FinancasMetaAPI {
        struct Body: Encodable {
            let valorAtualCentavos: Int

            enum CodingKeys: String, CodingKey {
                case valorAtualCentavos = "valor_atual_centavos"
            }
        }

        let response: APIResponse<FinancasMetaAPI> = try await APIClient.shared.request(
            endpoint: .financasMeta(id: id),
            method: .patch,
            body: Body(valorAtualCentavos: valorAtualCentavos),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }
}
