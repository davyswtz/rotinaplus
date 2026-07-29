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
        try await OfflineGateway.cachedFetch(key: .classes) {
            let response: APIResponse<[ClasseHeroi]> = try await APIClient.shared.request(
                endpoint: .classes,
                requiresAuth: false
            )
            guard let data = response.data else {
                throw APIError.invalidResponse
            }
            return data
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
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.amigoStats(id: id, periodo: periodo)) {
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
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.perfilStats(periodo: periodo)) {
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
        if var list = OfflineStore.shared.load([NotificacaoAPI].self, key: .notificacoes),
           let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].lida = true
            OfflineStore.shared.save(list, key: .notificacoes)
        }

        guard await MainActor.run(body: { NetworkMonitor.shared.isOnline }) else { return }

        do {
            let _: APIResponse<NotificacaoAPI> = try await APIClient.shared.request(
                endpoint: .marcarNotificacaoLida(id: id),
                method: .patch,
                requiresAuth: true
            )
        } catch {
            if Self.isLikelyNetworkFailure(error) { return }
            throw error
        }
    }

    static func lerTodasNotificacoes() async throws {
        if var list = OfflineStore.shared.load([NotificacaoAPI].self, key: .notificacoes) {
            for i in list.indices {
                list[i].lida = true
            }
            OfflineStore.shared.save(list, key: .notificacoes)
        }

        guard await MainActor.run(body: { NetworkMonitor.shared.isOnline }) else { return }

        do {
            struct Payload: Decodable {
                let atualizadas: Int?
            }
            let _: APIResponse<Payload> = try await APIClient.shared.request(
                endpoint: .lerTodasNotificacoes,
                method: .post,
                requiresAuth: true
            )
        } catch {
            if Self.isLikelyNetworkFailure(error) { return }
            throw error
        }
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
        let clientUUID = UUID().uuidString
        let payload = RegistrarEsportePayload(
            chave: chave,
            minutos: minutos,
            distanciaMetros: distanciaMetros,
            nota: nota,
            clientUUID: clientUUID
        )
        let tempId = -Int(Date().timeIntervalSince1970)
        var icone = "🏃"
        var nome = chave
        if let academia = OfflineStore.shared.load(AcademiaAPI.self, key: .academia),
           let esporte = academia.esportes?.first(where: { $0.chave == chave }) {
            icone = esporte.icone
            nome = esporte.nome
        }
        let offline = EsporteSessaoAPI(
            id: tempId,
            esporteChave: chave,
            icone: icone,
            nome: nome,
            minutos: minutos,
            distanciaMetros: distanciaMetros,
            xp: 0,
            data: Self.hojeChave(),
            nota: nota
        )

        if var academia = OfflineStore.shared.load(AcademiaAPI.self, key: .academia) {
            var sessoes = academia.esporteSessoes ?? []
            sessoes.insert(offline, at: 0)
            academia.esporteSessoes = sessoes
            OfflineStore.shared.save(academia, key: .academia)
        }

        return try await OfflineGateway.mutate(
            kind: .registrarEsporte,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteRegistrarEsporte(
                chave: chave,
                minutos: minutos,
                distanciaMetros: distanciaMetros,
                nota: nota,
                clientUUID: clientUUID
            )
        }
    }

    static func excluirEsporteSessao(id: Int) async throws {
        let payload = IdPayload(id: id)
        if var academia = OfflineStore.shared.load(AcademiaAPI.self, key: .academia) {
            academia.esporteSessoes?.removeAll { $0.id == id }
            OfflineStore.shared.save(academia, key: .academia)
        }
        try await OfflineGateway.mutate(kind: .excluirEsporteSessao, payload: payload) {
            try await remoteExcluirEsporteSessao(id: id)
        }
    }

    static func catalogoExercicios(grupo: String?) async throws -> ExercicioCatalogoDataAPI {
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.catalogo(grupo: grupo)) {
            let response: APIResponse<ExercicioCatalogoDataAPI> = try await APIClient.shared.request(
                endpoint: .academiaExercicios(grupo: grupo),
                method: .get,
                requiresAuth: true
            )
            guard let data = response.data else { throw APIError.invalidResponse }
            return data
        }
    }

    static func criarTreino(
        foco: String,
        titulo: String?,
        minutos: Int,
        exercicios: [TreinoExercicioPayload]
    ) async throws -> AcademiaTreinoAPI {
        let clientUUID = UUID().uuidString
        let payload = CriarTreinoPayload(
            foco: foco,
            titulo: titulo,
            minutos: minutos,
            exercicios: exercicios,
            clientUUID: clientUUID
        )
        let tempId = -Int(Date().timeIntervalSince1970)
        let itens = exercicios.enumerated().map { index, ex in
            AcademiaTreinoExercicioAPI(
                id: -(index + 1),
                exercicioChave: ex.exercicioChave,
                nome: ex.exercicioChave,
                icone: "💪",
                grupo: foco,
                series: ex.series,
                reps: ex.reps,
                cargaKg: ex.cargaKg,
                ordem: index + 1,
                concluido: false
            )
        }
        let offline = AcademiaTreinoAPI(
            id: tempId,
            foco: foco,
            titulo: titulo ?? foco,
            exercicios: exercicios.count,
            minutos: minutos,
            xp: 0,
            diaChave: Self.hojeChave(),
            ativo: true,
            concluidoEm: nil,
            volumeKg: nil,
            itens: itens
        )

        if var historico = OfflineStore.shared.load([AcademiaTreinoAPI].self, key: .historicoTreinos) {
            historico.insert(offline, at: 0)
            OfflineStore.shared.save(historico, key: .historicoTreinos)
        } else {
            OfflineStore.shared.save([offline], key: .historicoTreinos)
        }
        OfflineStore.shared.save(offline, key: OfflineCacheKey.treino(id: tempId))
        if var academia = OfflineStore.shared.load(AcademiaAPI.self, key: .academia) {
            academia.treinoHoje = offline
            OfflineStore.shared.save(academia, key: .academia)
        }

        return try await OfflineGateway.mutate(
            kind: .criarTreino,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteCriarTreino(
                foco: foco,
                titulo: titulo,
                minutos: minutos,
                exercicios: exercicios,
                clientUUID: clientUUID
            )
        }
    }

    static func historicoTreinos() async throws -> [AcademiaTreinoAPI] {
        try await OfflineGateway.cachedFetch(key: .historicoTreinos) {
            let response: APIResponse<[AcademiaTreinoAPI]> = try await APIClient.shared.request(
                endpoint: .academiaHistorico,
                method: .get,
                requiresAuth: true
            )
            return response.data ?? []
        }
    }

    static func detalheTreino(id: Int) async throws -> AcademiaTreinoAPI {
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.treino(id: id)) {
            let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
                endpoint: .treino(id: id),
                method: .get,
                requiresAuth: true
            )
            guard let data = response.data else { throw APIError.invalidResponse }
            return data
        }
    }

    static func toggleTreinoExercicio(treinoId: Int, exercicioId: Int, concluido: Bool) async throws {
        let payload = ToggleTreinoExercicioPayload(
            treinoId: treinoId,
            exercicioId: exercicioId,
            concluido: concluido
        )

        let treinoKey = OfflineCacheKey.treino(id: treinoId)
        if var treino = OfflineStore.shared.load(AcademiaTreinoAPI.self, key: treinoKey),
           let idx = treino.itens?.firstIndex(where: { $0.id == exercicioId }) {
            treino.itens?[idx].concluido = concluido
            OfflineStore.shared.save(treino, key: treinoKey)
        }
        if var historico = OfflineStore.shared.load([AcademiaTreinoAPI].self, key: .historicoTreinos),
           let idx = historico.firstIndex(where: { $0.id == treinoId }),
           let itemIdx = historico[idx].itens?.firstIndex(where: { $0.id == exercicioId }) {
            historico[idx].itens?[itemIdx].concluido = concluido
            OfflineStore.shared.save(historico, key: .historicoTreinos)
        }

        try await OfflineGateway.mutate(kind: .toggleTreinoExercicio, payload: payload) {
            try await remoteToggleTreinoExercicio(
                treinoId: treinoId,
                exercicioId: exercicioId,
                concluido: concluido
            )
        }
    }

    static func concluirTreino(id: Int) async throws -> AcademiaTreinoAPI {
        let payload = IdPayload(id: id)
        let offline: AcademiaTreinoAPI = {
            if var treino = OfflineStore.shared.load(AcademiaTreinoAPI.self, key: OfflineCacheKey.treino(id: id)) {
                treino.concluidoEm = Self.hojeChave()
                treino.ativo = false
                OfflineStore.shared.save(treino, key: OfflineCacheKey.treino(id: id))
                if var historico = OfflineStore.shared.load([AcademiaTreinoAPI].self, key: .historicoTreinos),
                   let idx = historico.firstIndex(where: { $0.id == id }) {
                    historico[idx] = treino
                    OfflineStore.shared.save(historico, key: .historicoTreinos)
                }
                return treino
            }
            return AcademiaTreinoAPI(
                id: id,
                foco: "",
                titulo: "",
                exercicios: 0,
                minutos: 0,
                xp: 0,
                diaChave: Self.hojeChave(),
                ativo: false,
                concluidoEm: Self.hojeChave(),
                volumeKg: nil,
                itens: nil
            )
        }()

        return try await OfflineGateway.mutate(
            kind: .concluirTreino,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteConcluirTreino(id: id)
        }
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

        if var journal = OfflineStore.shared.load(HabitoJournalAPI.self, key: OfflineCacheKey.habitos(data: nil)) {
            journal.itens.append(
                HabitoItemJournalAPI(habito: offline, checkin: nil, concluida: false, streak: 0)
            )
            journal.resumo.total += 1
            OfflineStore.shared.save(journal, key: OfflineCacheKey.habitos(data: nil))
        }

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

        if var journal = OfflineStore.shared.load(HabitoJournalAPI.self, key: OfflineCacheKey.habitos(data: data)),
           let idx = journal.itens.firstIndex(where: { $0.habito.id == id }) {
            journal.itens[idx].concluida = concluida
            journal.itens[idx].checkin = offlineCheckin
            if concluida {
                journal.resumo.concluidos = min(journal.resumo.concluidos + 1, journal.resumo.total)
            } else {
                journal.resumo.concluidos = max(journal.resumo.concluidos - 1, 0)
            }
            if journal.resumo.total > 0 {
                journal.resumo.percentual = journal.resumo.concluidos * 100 / journal.resumo.total
            }
            OfflineStore.shared.save(journal, key: OfflineCacheKey.habitos(data: data))
        }

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
        let payload = IdPayload(id: id)
        if var journal = OfflineStore.shared.load(HabitoJournalAPI.self, key: OfflineCacheKey.habitos(data: nil)) {
            journal.itens.removeAll { $0.habito.id == id }
            OfflineStore.shared.save(journal, key: OfflineCacheKey.habitos(data: nil))
        }
        try await OfflineGateway.mutate(kind: .excluirHabito, payload: payload) {
            try await remoteExcluirHabito(id: id)
        }
    }

    static func financas(mes: String? = nil) async throws -> FinancasAPI {
        try await OfflineGateway.cachedFetch(key: OfflineCacheKey.financas(mes: mes)) {
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
        let clientUUID = UUID().uuidString
        let payload = CriarTransacaoPayload(
            tipo: tipo,
            categoria: categoria,
            titulo: titulo,
            icone: icone,
            valorCentavos: valorCentavos,
            data: data,
            clientUUID: clientUUID
        )
        let tempId = -Int(Date().timeIntervalSince1970)
        var categoriaNome = categoria
        var categoriaCor = "#888888"
        let mes = String(data.prefix(7))
        if let financas = OfflineStore.shared.load(FinancasAPI.self, key: OfflineCacheKey.financas(mes: mes)) {
            if tipo == "receita" {
                categoriaNome = financas.categorias.receita.nome
                categoriaCor = financas.categorias.receita.cor
            } else if let cat = financas.categorias.despesas.first(where: { $0.chave == categoria }) {
                categoriaNome = cat.nome
                categoriaCor = cat.cor
            }
        }
        let offline = FinancasTransacaoAPI(
            id: tempId,
            tipo: tipo,
            categoria: categoria,
            categoriaNome: categoriaNome,
            categoriaCor: categoriaCor,
            titulo: titulo,
            icone: icone ?? "💰",
            valorCentavos: valorCentavos,
            data: data,
            origem: "manual"
        )

        Self.patchFinancasCache(mes: mes) { financas in
            financas.transacoes.insert(offline, at: 0)
            financas.recentes.insert(offline, at: 0)
            if tipo == "receita" {
                financas.receitaCentavos += valorCentavos
            } else {
                financas.gastosCentavos += valorCentavos
            }
            financas.saldoCentavos = financas.receitaCentavos - financas.gastosCentavos
        }

        return try await OfflineGateway.mutate(
            kind: .criarTransacao,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteCriarTransacao(payload)
        }
    }

    static func excluirTransacao(id: Int) async throws {
        let payload = IdPayload(id: id)
        Self.patchFinancasCache(mes: nil) { financas in
            if let tx = financas.transacoes.first(where: { $0.id == id }) {
                if tx.isReceita {
                    financas.receitaCentavos -= tx.valorCentavos
                } else {
                    financas.gastosCentavos -= tx.valorCentavos
                }
                financas.saldoCentavos = financas.receitaCentavos - financas.gastosCentavos
            }
            financas.transacoes.removeAll { $0.id == id }
            financas.recentes.removeAll { $0.id == id }
        }
        try await OfflineGateway.mutate(kind: .excluirTransacao, payload: payload) {
            try await remoteExcluirTransacao(id: id)
        }
    }

    static func criarMeta(
        titulo: String,
        icone: String?,
        valorAlvoCentavos: Int
    ) async throws -> FinancasMetaAPI {
        let clientUUID = UUID().uuidString
        let payload = CriarMetaPayload(
            titulo: titulo,
            icone: icone,
            valorAlvoCentavos: valorAlvoCentavos,
            clientUUID: clientUUID
        )
        let offline = FinancasMetaAPI(
            id: -Int(Date().timeIntervalSince1970),
            titulo: titulo,
            icone: icone ?? "🎯",
            categoria: nil,
            valorAlvoCentavos: valorAlvoCentavos,
            valorAtualCentavos: 0,
            percentual: 0
        )

        Self.patchFinancasCache(mes: nil) { financas in
            financas.metas.append(offline)
        }

        return try await OfflineGateway.mutate(
            kind: .criarMeta,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteCriarMeta(payload)
        }
    }

    static func atualizarMeta(id: Int, valorAtualCentavos: Int) async throws -> FinancasMetaAPI {
        let payload = AtualizarMetaPayload(
            id: id,
            titulo: nil,
            valorAlvoCentavos: nil,
            valorAtualCentavos: valorAtualCentavos
        )
        let offline: FinancasMetaAPI = {
            var result = FinancasMetaAPI(
                id: id,
                titulo: "",
                icone: "🎯",
                categoria: nil,
                valorAlvoCentavos: 1,
                valorAtualCentavos: valorAtualCentavos,
                percentual: 0
            )
            Self.patchFinancasCache(mes: nil) { financas in
                if let idx = financas.metas.firstIndex(where: { $0.id == id }) {
                    financas.metas[idx].valorAtualCentavos = valorAtualCentavos
                    let alvo = max(financas.metas[idx].valorAlvoCentavos, 1)
                    financas.metas[idx].percentual = Double(valorAtualCentavos) / Double(alvo) * 100
                    result = financas.metas[idx]
                }
            }
            return result
        }()

        return try await OfflineGateway.mutate(
            kind: .atualizarMeta,
            payload: payload,
            offlineValue: offline
        ) {
            try await remoteAtualizarMeta(payload)
        }
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

// MARK: - Offline helpers

private extension RotinaPlusAPI {
    static func hojeChave() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        return formatter.string(from: Date())
    }

    static func isLikelyNetworkFailure(_ error: Error) -> Bool {
        if let url = error as? URLError {
            switch url.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost,
                 .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed,
                 .internationalRoamingOff, .dataNotAllowed:
                return true
            default:
                return false
            }
        }
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain { return true }
        return false
    }

    static func patchFinancasCache(mes: String?, _ update: (inout FinancasAPI) -> Void) {
        let keys: [String]
        if let mes, !mes.isEmpty {
            keys = [OfflineCacheKey.financas(mes: mes), OfflineCacheKey.financas(mes: nil)]
        } else {
            keys = [OfflineCacheKey.financas(mes: nil)]
        }
        var patchedAny = false
        for key in keys {
            if var financas = OfflineStore.shared.load(FinancasAPI.self, key: key) {
                update(&financas)
                OfflineStore.shared.save(financas, key: key)
                patchedAny = true
            }
        }
        // Primeira criação offline sem snapshot prévio: shell mínimo para a UI.
        if !patchedAny {
            let mesKey = mes ?? Self.mesAtualChave()
            var shell = FinancasAPI(
                anoMes: mesKey,
                mesLabel: mesKey,
                meses: [],
                saldoCentavos: 0,
                receitaCentavos: 0,
                gastosCentavos: 0,
                serieMensal: [],
                distribuicao: [],
                recentes: [],
                transacoes: [],
                metas: [],
                categorias: FinancasCategoriasAPI(
                    despesas: [
                        FinancasCategoriaAPI(chave: "geral", nome: "Geral", cor: "#888888", icone: "💸")
                    ],
                    receita: FinancasCategoriaAPI(chave: "receita", nome: "Receita", cor: "#2ECC71", icone: "💰")
                ),
                pluggy: nil
            )
            update(&shell)
            OfflineStore.shared.save(shell, key: OfflineCacheKey.financas(mes: mes))
            OfflineStore.shared.save(shell, key: OfflineCacheKey.financas(mes: nil))
        }
    }

    static func mesAtualChave() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
