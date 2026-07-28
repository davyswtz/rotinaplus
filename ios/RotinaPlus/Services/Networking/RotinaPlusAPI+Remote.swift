import Foundation

/// Chamadas de replay da fila offline (estado absoluto + client_uuid).
extension RotinaPlusAPI {
    static func remoteToggleMissao(id: Int, concluida: Bool) async throws -> MissaoAPI {
        struct Body: Encodable {
            let concluida: Bool
        }

        let response: APIResponse<MissaoAPI> = try await APIClient.shared.request(
            endpoint: .toggleMissao(id: id),
            method: .patch,
            body: Body(concluida: concluida),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteCriarMissao(
        titulo: String,
        detalhe: String?,
        icone: String,
        clientUUID: String
    ) async throws -> MissaoAPI {
        struct Body: Encodable {
            let titulo: String
            let detalhe: String?
            let icone: String
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case titulo, detalhe, icone
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<MissaoAPI> = try await APIClient.shared.request(
            endpoint: .missoes,
            method: .post,
            body: Body(
                titulo: titulo,
                detalhe: detalhe,
                icone: icone,
                clientUUID: clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteToggleHabitoCheckin(
        id: Int,
        data: String?,
        humor: Int?,
        nota: String?,
        concluida: Bool
    ) async throws -> HabitoToggleResultAPI {
        struct Body: Encodable {
            let data: String?
            let humor: Int?
            let nota: String?
            let concluida: Bool
        }

        let response: APIResponse<HabitoToggleResultAPI> = try await APIClient.shared.request(
            endpoint: .toggleHabitoCheckin(id: id),
            method: .patch,
            body: Body(data: data, humor: humor, nota: nota, concluida: concluida),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteCriarHabito(
        titulo: String,
        detalhe: String?,
        icone: String,
        area: String,
        clientUUID: String
    ) async throws -> HabitoAPI {
        struct Body: Encodable {
            let titulo: String
            let detalhe: String?
            let icone: String
            let area: String
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case titulo, detalhe, icone, area
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<HabitoAPI> = try await APIClient.shared.request(
            endpoint: .criarHabito,
            method: .post,
            body: Body(
                titulo: titulo,
                detalhe: detalhe,
                icone: icone,
                area: area,
                clientUUID: clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteAtualizarHabitoNota(
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

    static func remoteToggleAcademiaDia(id: Int, concluido: Bool) async throws {
        struct Body: Encodable {
            let concluido: Bool
        }
        struct DiaToggle: Decodable {
            let id: Int
            let concluido: Bool
        }

        let _: APIResponse<DiaToggle> = try await APIClient.shared.request(
            endpoint: .toggleAcademiaDia(id: id),
            method: .patch,
            body: Body(concluido: concluido),
            requiresAuth: true
        )
    }

    static func remoteRegistrarEsporte(
        chave: String,
        minutos: Int,
        distanciaMetros: Int?,
        nota: String?,
        clientUUID: String
    ) async throws -> EsporteSessaoAPI {
        struct Body: Encodable {
            let esporteChave: String
            let minutos: Int
            let distanciaMetros: Int?
            let nota: String?
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case minutos, nota
                case esporteChave = "esporte_chave"
                case distanciaMetros = "distancia_metros"
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<EsporteSessaoAPI> = try await APIClient.shared.request(
            endpoint: .registrarEsporte,
            method: .post,
            body: Body(
                esporteChave: chave,
                minutos: minutos,
                distanciaMetros: distanciaMetros,
                nota: nota,
                clientUUID: clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteExcluirEsporteSessao(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .excluirEsporteSessao(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    static func remoteCriarTreino(
        foco: String,
        titulo: String?,
        minutos: Int,
        exercicios: [TreinoExercicioPayload],
        clientUUID: String
    ) async throws -> AcademiaTreinoAPI {
        struct Body: Encodable {
            let foco: String
            let titulo: String?
            let minutos: Int
            let exercicios: [TreinoExercicioPayload]
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case foco, titulo, minutos, exercicios
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
            endpoint: .criarTreino,
            method: .post,
            body: Body(
                foco: foco,
                titulo: titulo,
                minutos: minutos,
                exercicios: exercicios,
                clientUUID: clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func remoteToggleTreinoExercicio(
        treinoId: Int,
        exercicioId: Int,
        concluido: Bool
    ) async throws {
        struct Body: Encodable {
            let concluido: Bool
        }
        struct Payload: Decodable {
            let id: Int
            let concluido: Bool
        }

        let _: APIResponse<Payload> = try await APIClient.shared.request(
            endpoint: .toggleTreinoExercicio(treinoId: treinoId, exercicioId: exercicioId),
            method: .patch,
            body: Body(concluido: concluido),
            requiresAuth: true
        )
    }

    static func remoteConcluirTreino(id: Int) async throws -> AcademiaTreinoAPI {
        let response: APIResponse<AcademiaTreinoAPI> = try await APIClient.shared.request(
            endpoint: .concluirTreino(id: id),
            method: .post,
            requiresAuth: true
        )
        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    static func remoteCriarTransacao(_ payload: CriarTransacaoPayload) async throws -> FinancasTransacaoAPI {
        struct Body: Encodable {
            let tipo: String
            let categoria: String
            let titulo: String
            let icone: String?
            let valorCentavos: Int
            let data: String
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case tipo, categoria, titulo, icone, data
                case valorCentavos = "valor_centavos"
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<FinancasTransacaoAPI> = try await APIClient.shared.request(
            endpoint: .financasTransacoes,
            method: .post,
            body: Body(
                tipo: payload.tipo,
                categoria: payload.categoria,
                titulo: payload.titulo,
                icone: payload.icone,
                valorCentavos: payload.valorCentavos,
                data: payload.data ?? Self.hojeChave(),
                clientUUID: payload.clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteExcluirTransacao(id: Int) async throws {
        struct Empty: Decodable {}
        let _: APIResponse<Empty> = try await APIClient.shared.request(
            endpoint: .financasTransacao(id: id),
            method: .delete,
            requiresAuth: true
        )
    }

    static func remoteCriarMeta(_ payload: CriarMetaPayload) async throws -> FinancasMetaAPI {
        struct Body: Encodable {
            let titulo: String
            let icone: String?
            let valorAlvoCentavos: Int
            let clientUUID: String

            enum CodingKeys: String, CodingKey {
                case titulo, icone
                case valorAlvoCentavos = "valor_alvo_centavos"
                case clientUUID = "client_uuid"
            }
        }

        let response: APIResponse<FinancasMetaAPI> = try await APIClient.shared.request(
            endpoint: .financasMetas,
            method: .post,
            body: Body(
                titulo: payload.titulo,
                icone: payload.icone,
                valorAlvoCentavos: payload.valorAlvoCentavos,
                clientUUID: payload.clientUUID
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    static func remoteAtualizarMeta(_ payload: AtualizarMetaPayload) async throws -> FinancasMetaAPI {
        struct Body: Encodable {
            var titulo: String?
            var valorAlvoCentavos: Int?
            var valorAtualCentavos: Int?

            enum CodingKeys: String, CodingKey {
                case titulo
                case valorAlvoCentavos = "valor_alvo_centavos"
                case valorAtualCentavos = "valor_atual_centavos"
            }

            func encode(to encoder: Encoder) throws {
                var c = encoder.container(keyedBy: CodingKeys.self)
                if let titulo { try c.encode(titulo, forKey: .titulo) }
                if let valorAlvoCentavos { try c.encode(valorAlvoCentavos, forKey: .valorAlvoCentavos) }
                if let valorAtualCentavos { try c.encode(valorAtualCentavos, forKey: .valorAtualCentavos) }
            }
        }

        let response: APIResponse<FinancasMetaAPI> = try await APIClient.shared.request(
            endpoint: .financasMeta(id: payload.id),
            method: .patch,
            body: Body(
                titulo: payload.titulo,
                valorAlvoCentavos: payload.valorAlvoCentavos,
                valorAtualCentavos: payload.valorAtualCentavos
            ),
            requiresAuth: true
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        return data
    }

    private static func hojeChave() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        return formatter.string(from: Date())
    }

    static func remoteAtualizarPerfilCampos(
        nomeHeroi: String? = nil,
        avatarKey: String? = nil,
        classe: String? = nil,
        emojiClasse: String? = nil
    ) async throws -> PerfilAPI {
        struct Body: Encodable {
            var nomeHeroi: String?
            var avatarKey: String?
            var classe: String?
            var emojiClasse: String?

            enum CodingKeys: String, CodingKey {
                case nomeHeroi = "nome_heroi"
                case avatarKey = "avatar_key"
                case classe
                case emojiClasse = "emoji_classe"
            }

            func encode(to encoder: Encoder) throws {
                var c = encoder.container(keyedBy: CodingKeys.self)
                if let nomeHeroi { try c.encode(nomeHeroi, forKey: .nomeHeroi) }
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
}
