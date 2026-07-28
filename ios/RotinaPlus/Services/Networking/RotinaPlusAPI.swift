import Foundation

/// Camada de API do app (dashboard, missões, academia, notificações).
enum RotinaPlusAPI {
    static func dashboard() async throws -> DashboardAPI {
        try await OfflineGateway.cachedFetch(key: .dashboard) {
            let response: APIResponse<DashboardAPI> = try await APIClient.shared.request(
                endpoint: .dashboard,
                requiresAuth: true
            )
            guard let data = response.data else {
                throw APIError.invalidResponse
            }
            return data
        }
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
        avatarKey: String? = nil,
        classe: String? = nil,
        emojiClasse: String? = nil
    ) async throws -> PerfilAPI {
        let payload = AtualizarPerfilPayload(
            nomeHeroi: nomeHeroi,
            avatarKey: avatarKey,
            classe: classe,
            emojiClasse: emojiClasse
        )
        let offline: PerfilAPI = {
            if var dash = OfflineStore.shared.load(DashboardAPI.self, key: .dashboard) {
                if let nomeHeroi { dash.perfil.nomeHeroi = nomeHeroi }
                if let avatarKey { dash.perfil.avatarKey = avatarKey }
                if let classe { dash.perfil.classe = classe }
                if let emojiClasse { dash.perfil.emojiClasse = emojiClasse }
                OfflineStore.shared.save(dash, key: .dashboard)
                return dash.perfil
            }
            return PerfilAPI(
                nomeHeroi: nomeHeroi,
                codigoAmigo: nil,
                avatarKey: avatarKey ?? "guara_serio",
                classe: classe ?? "",
                emojiClasse: emojiClasse ?? "",
                nivel: 1,
                xpAtual: 0,
                xpProximoNivel: 500,
                moedas: 0,
                streakDias: 0
            )
        }()

        return try await OfflineGateway.mutate(
            kind: .atualizarPerfil,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteAtualizarPerfilCampos(
                nomeHeroi: nomeHeroi,
                avatarKey: avatarKey,
                classe: classe,
                emojiClasse: emojiClasse
            )
        }
    }

    static func listarAmigos() async throws -> AmigosListaAPI {
        try await OfflineGateway.cachedFetch(key: .amigos) {
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
    }

    static func convidarAmigo(codigo: String) async throws -> ConviteAmigoRespostaAPI {
        struct Body: Encodable { let codigo: String }
        let response: APIResponse<ConviteAmigoRespostaAPI> = try await APIClient.shared.request(
            endpoint: .adicionarAmigo,
            method: .post,
            body: Body(codigo: codigo),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func statsAmigo(id: Int, periodo: String = "semana") async throws -> AmigoStatsAPI {
        let response: APIResponse<AmigoStatsAPI> = try await APIClient.shared.request(
            endpoint: .statsAmigo(id: id, periodo: periodo),
            method: .get,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func aceitarAmigo(amizadeId: Int) async throws -> AmigoAPI {
        let response: APIResponse<AmigoAPI> = try await APIClient.shared.request(
            endpoint: .aceitarAmigo(id: amizadeId),
            method: .post,
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func recusarAmigo(amizadeId: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .recusarAmigo(id: amizadeId),
            method: .post,
            requiresAuth: true
        )
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

    static func toggleMissao(id: Int, concluida: Bool) async throws -> MissaoAPI {
        let payload = ToggleMissaoPayload(id: id, concluida: concluida)
        let offline = MissaoAPI(
            id: id,
            icone: "🎯",
            titulo: "",
            detalhe: nil,
            xp: 0,
            concluida: concluida,
            data: nil,
            ordem: nil
        )

        // Atualiza snapshot do dashboard localmente.
        if var dash = OfflineStore.shared.load(DashboardAPI.self, key: .dashboard),
           let idx = dash.missoes.firstIndex(where: { $0.id == id }) {
            dash.missoes[idx].concluida = concluida
            OfflineStore.shared.save(dash, key: .dashboard)
        }

        return try await OfflineGateway.mutate(
            kind: .toggleMissao,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteToggleMissao(id: id, concluida: concluida)
        }
    }

    static func criarMissao(
        titulo: String,
        detalhe: String?,
        icone: String
    ) async throws -> MissaoAPI {
        let clientUUID = UUID().uuidString
        let payload = CriarMissaoPayload(
            titulo: titulo,
            detalhe: detalhe,
            icone: icone,
            clientUUID: clientUUID
        )
        let tempId = -Int(Date().timeIntervalSince1970)
        let offline = MissaoAPI(
            id: tempId,
            icone: icone,
            titulo: titulo,
            detalhe: detalhe,
            xp: 35,
            concluida: false,
            data: nil,
            ordem: nil
        )

        if var dash = OfflineStore.shared.load(DashboardAPI.self, key: .dashboard) {
            dash.missoes.append(offline)
            OfflineStore.shared.save(dash, key: .dashboard)
        }

        return try await OfflineGateway.mutate(
            kind: .criarMissao,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteCriarMissao(
                titulo: titulo,
                detalhe: detalhe,
                icone: icone,
                clientUUID: clientUUID
            )
        }
    }

    static func notificacoes() async throws -> [NotificacaoAPI] {
        try await OfflineGateway.cachedFetch(key: .notificacoes) {
            let response: APIResponse<[NotificacaoAPI]> = try await APIClient.shared.request(
                endpoint: .notificacoes,
                requiresAuth: true
            )
            return response.data ?? []
        }
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
        try await OfflineGateway.cachedFetch(key: .academia) {
            let response: APIResponse<AcademiaAPI> = try await APIClient.shared.request(
                endpoint: .academia,
                requiresAuth: true
            )
            guard let data = response.data else {
                throw APIError.invalidResponse
            }
            return data
        }
    }

    static func toggleAcademiaDia(id: Int, concluido: Bool) async throws {
        let payload = ToggleAcademiaDiaPayload(id: id, concluido: concluido)
        if var academia = OfflineStore.shared.load(AcademiaAPI.self, key: .academia),
           let idx = academia.dias.firstIndex(where: { $0.id == id }) {
            academia.dias[idx].concluido = concluido
            OfflineStore.shared.save(academia, key: .academia)
        }
        try await OfflineGateway.mutate(kind: .toggleAcademiaDia, payload: payload) {
            try await remoteToggleAcademiaDia(id: id, concluido: concluido)
        }
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
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.habitos(data: data)) {
            let response: APIResponse<HabitoJournalAPI> = try await APIClient.shared.request(
                endpoint: .habitos(data: data),
                requiresAuth: true
            )
            guard let data = response.data else {
                throw APIError.invalidResponse
            }
            return data
        }
    }

    static func criarHabito(
        titulo: String,
        detalhe: String?,
        icone: String,
        area: String
    ) async throws -> HabitoAPI {
        let clientUUID = UUID().uuidString
        let payload = CriarHabitoPayload(
            titulo: titulo,
            detalhe: detalhe,
            icone: icone,
            area: area,
            clientUUID: clientUUID
        )
        let offline = HabitoAPI(
            id: -Int(Date().timeIntervalSince1970),
            icone: icone,
            titulo: titulo,
            detalhe: detalhe,
            area: area,
            frequencia: "diario",
            diasSemana: nil,
            xp: 20,
            ativo: true,
            ordem: nil
        )
        return try await OfflineGateway.mutate(
            kind: .criarHabito,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteCriarHabito(
                titulo: titulo,
                detalhe: detalhe,
                icone: icone,
                area: area,
                clientUUID: clientUUID
            )
        }
    }

    static func toggleHabitoCheckin(
        id: Int,
        data: String?,
        humor: Int?,
        nota: String?,
        concluida: Bool
    ) async throws -> HabitoToggleResultAPI {
        let payload = ToggleHabitoPayload(
            id: id,
            data: data,
            humor: humor,
            nota: nota,
            concluida: concluida
        )
        let offlineHabito = HabitoAPI(
            id: id,
            icone: "✨",
            titulo: "",
            detalhe: nil,
            area: "geral",
            frequencia: "diario",
            diasSemana: nil,
            xp: 0,
            ativo: true,
            ordem: nil
        )
        let offlineCheckin = HabitoCheckinAPI(
            id: 0,
            habitoId: id,
            data: data,
            concluida: concluida,
            concluidaEm: nil,
            humor: humor,
            nota: nota
        )
        let offline = HabitoToggleResultAPI(
            habito: offlineHabito,
            checkin: offlineCheckin,
            concluida: concluida,
            streak: 0,
            bonusDia: nil
        )
        return try await OfflineGateway.mutate(
            kind: .toggleHabitoCheckin,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteToggleHabitoCheckin(
                id: id,
                data: data,
                humor: humor,
                nota: nota,
                concluida: concluida
            )
        }
    }

    static func atualizarHabitoNota(
        id: Int,
        data: String?,
        nota: String?,
        humor: Int?
    ) async throws -> HabitoCheckinAPI {
        let payload = HabitoNotaPayload(id: id, data: data, nota: nota, humor: humor)
        let offline = HabitoCheckinAPI(
            id: 0,
            habitoId: id,
            data: data,
            concluida: false,
            concluidaEm: nil,
            humor: humor,
            nota: nota
        )
        return try await OfflineGateway.mutate(
            kind: .atualizarHabitoNota,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteAtualizarHabitoNota(id: id, data: data, nota: nota, humor: humor)
        }
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
        let key = mes.map { "financas_\($0)" } ?? OfflineCacheKey.financas.rawValue
        return try await OfflineGateway.cachedFetch(key: key) {
            let response: APIResponse<FinancasAPI> = try await APIClient.shared.request(
                endpoint: .financas(mes: mes),
                requiresAuth: true
            )
            guard let data = response.data else {
                throw APIError.invalidResponse
            }
            return data
        }
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
