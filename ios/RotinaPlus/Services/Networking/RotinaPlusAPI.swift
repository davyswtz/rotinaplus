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

    static func classes() async throws -> [ClasseHeroi] {
        struct Item: Decodable {
            let key: String
            let nome: String
            let emoji: String
            let descricao: String
            let bonus: [String]
            let tema: String
        }

        let response: APIResponse<[Item]> = try await APIClient.shared.request(
            endpoint: .classes,
            requiresAuth: false
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data.map {
            ClasseHeroi(
                key: $0.key,
                nome: $0.nome,
                emoji: $0.emoji,
                descricao: $0.descricao,
                bonus: $0.bonus,
                tema: $0.tema
            )
        }
    }

    static func updatePerfil(
        nomeHeroi: String,
        avatarKey: String,
        classe: String,
        emojiClasse: String
    ) async throws -> PerfilAPI {
        try await atualizarPerfilCampos(
            nomeHeroi: nomeHeroi,
            avatarKey: avatarKey,
            classe: classe,
            emojiClasse: emojiClasse
        )
    }

    static func atualizarPerfilCampos(
        nomeHeroi: String? = nil,
        nick: String? = nil,
        avatarKey: String? = nil,
        classe: String? = nil,
        emojiClasse: String? = nil
    ) async throws -> PerfilAPI {
        struct Body: Encodable {
            var nomeHeroi: String?
            var nick: String?
            var avatarKey: String?
            var classe: String?
            var emojiClasse: String?

            enum CodingKeys: String, CodingKey {
                case nomeHeroi = "nome_heroi"
                case nick
                case avatarKey = "avatar_key"
                case classe
                case emojiClasse = "emoji_classe"
            }

            func encode(to encoder: Encoder) throws {
                var c = encoder.container(keyedBy: CodingKeys.self)
                if let nomeHeroi { try c.encode(nomeHeroi, forKey: .nomeHeroi) }
                if let nick { try c.encode(nick, forKey: .nick) }
                if let avatarKey { try c.encode(avatarKey, forKey: .avatarKey) }
                if let classe { try c.encode(classe, forKey: .classe) }
                if let emojiClasse { try c.encode(emojiClasse, forKey: .emojiClasse) }
            }
        }

        let response: APIResponse<PerfilAPI> = try await APIClient.shared.request(
            endpoint: .perfil,
            method: .put,
            body: Body(
                nomeHeroi: nomeHeroi,
                nick: nick,
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

    static func listarAmigos() async throws -> AmigosListaAPI {
        let response: APIResponse<AmigosListaAPI> = try await APIClient.shared.request(
            endpoint: .amigos,
            method: .get,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func adicionarAmigo(nick: String) async throws -> AmigoAPI {
        struct Body: Encodable { let nick: String }
        let response: APIResponse<AmigoAPI> = try await APIClient.shared.request(
            endpoint: .adicionarAmigo,
            method: .post,
            body: Body(nick: nick),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func removerAmigo(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .removerAmigo(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    static func perfilStats(periodo: String = "semana") async throws -> PerfilStatsAPI {
        let response: APIResponse<PerfilStatsAPI> = try await APIClient.shared.request(
            endpoint: .perfilStats(periodo: periodo),
            method: .get,
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

    static func registrarEsporte(
        chave: String,
        minutos: Int,
        distanciaMetros: Int?,
        nota: String?
    ) async throws -> EsporteSessaoAPI {
        struct Body: Encodable {
            let esporteChave: String
            let minutos: Int
            let distanciaMetros: Int?
            let nota: String?

            enum CodingKeys: String, CodingKey {
                case minutos, nota
                case esporteChave = "esporte_chave"
                case distanciaMetros = "distancia_metros"
            }
        }
        let response: APIResponse<EsporteSessaoAPI> = try await APIClient.shared.request(
            endpoint: .registrarEsporte,
            method: .post,
            body: Body(
                esporteChave: chave,
                minutos: minutos,
                distanciaMetros: distanciaMetros,
                nota: nota
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func excluirEsporteSessao(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .excluirEsporteSessao(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    static func catalogoExercicios(grupo: String?) async throws -> ExercicioCatalogoDataAPI {
        let response: APIResponse<ExercicioCatalogoDataAPI> = try await APIClient.shared.request(
            endpoint: .academiaExercicios(grupo: grupo),
            method: .get,
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func criarTreino(
        foco: String,
        titulo: String?,
        minutos: Int,
        exercicios: [TreinoExercicioPayload]
    ) async throws -> AcademiaTreinoAPI {
        struct Body: Encodable {
            let foco: String
            let titulo: String?
            let minutos: Int
            let exercicios: [TreinoExercicioPayload]
        }

        let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
            endpoint: .criarTreino,
            method: .post,
            body: Body(foco: foco, titulo: titulo, minutos: minutos, exercicios: exercicios),
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func historicoTreinos() async throws -> [AcademiaTreinoAPI] {
        let response: APIResponse<[AcademiaTreinoAPI]> = try await APIClient.shared.request(
            endpoint: .academiaHistorico,
            method: .get,
            requiresAuth: true
        )
        return response.data ?? []
    }

    static func detalheTreino(id: Int) async throws -> AcademiaTreinoAPI {
        let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
            endpoint: .treino(id: id),
            method: .get,
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func toggleTreinoExercicio(treinoId: Int, exercicioId: Int) async throws {
        struct Payload: Decodable {
            let id: Int
            let concluido: Bool
        }
        let _: APIResponse<Payload> = try await APIClient.shared.request(
            endpoint: .toggleTreinoExercicio(treinoId: treinoId, exercicioId: exercicioId),
            method: .patch,
            requiresAuth: true
        )
    }

    static func concluirTreino(id: Int) async throws -> AcademiaTreinoAPI {
        let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
            endpoint: .concluirTreino(id: id),
            method: .post,
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func habitos(data: String? = nil) async throws -> HabitoJournalAPI {
        let response: APIResponse<HabitoJournalAPI> = try await APIClient.shared.request(
            endpoint: .habitos(data: data),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func criarHabito(
        titulo: String,
        detalhe: String?,
        icone: String,
        area: String
    ) async throws -> HabitoAPI {
        struct Body: Encodable {
            let titulo: String
            let detalhe: String?
            let icone: String
            let area: String
        }
        let response: APIResponse<HabitoAPI> = try await APIClient.shared.request(
            endpoint: .criarHabito,
            method: .post,
            body: Body(titulo: titulo, detalhe: detalhe, icone: icone, area: area),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func toggleHabitoCheckin(
        id: Int,
        data: String?,
        humor: Int?,
        nota: String?
    ) async throws -> HabitoToggleResultAPI {
        struct Body: Encodable {
            let data: String?
            let humor: Int?
            let nota: String?
        }
        let response: APIResponse<HabitoToggleResultAPI> = try await APIClient.shared.request(
            endpoint: .toggleHabitoCheckin(id: id),
            method: .patch,
            body: Body(data: data, humor: humor, nota: nota),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func atualizarHabitoNota(
        id: Int,
        data: String?,
        nota: String?,
        humor: Int?
    ) async throws -> HabitoCheckinAPI {
        struct Body: Encodable {
            let data: String?
            let nota: String?
            let humor: Int?
        }
        let response: APIResponse<HabitoCheckinAPI> = try await APIClient.shared.request(
            endpoint: .atualizarHabitoNota(id: id),
            method: .patch,
            body: Body(data: data, nota: nota, humor: humor),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func excluirHabito(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .excluirHabito(id: id),
            method: .delete,
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

    static func pluggyConnectToken() async throws -> PluggyConnectTokenAPI {
        let response: APIResponse<PluggyConnectTokenAPI> = try await APIClient.shared.request(
            endpoint: .pluggyConnectToken,
            method: .post,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func pluggyVincular(itemId: String) async throws -> PluggySyncResultAPI {
        struct Body: Encodable {
            let itemId: String
            enum CodingKeys: String, CodingKey { case itemId = "item_id" }
        }
        let response: APIResponse<PluggySyncResultAPI> = try await APIClient.shared.request(
            endpoint: .pluggyVincular,
            method: .post,
            body: Body(itemId: itemId),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func pluggySincronizar() async throws -> PluggySyncResultAPI {
        let response: APIResponse<PluggySyncResultAPI> = try await APIClient.shared.request(
            endpoint: .pluggySincronizar,
            method: .post,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }
}
