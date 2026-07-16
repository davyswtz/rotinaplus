import Foundation

// MARK: - Perfil / Dashboard (API)

struct PerfilAPI: Codable, Equatable {
    var nomeHeroi: String?
    var avatarKey: String
    var classe: String
    var emojiClasse: String
    var nivel: Int
    var xpAtual: Int
    var xpProximoNivel: Int
    var moedas: Int
    var streakDias: Int

    enum CodingKeys: String, CodingKey {
        case nomeHeroi = "nome_heroi"
        case avatarKey = "avatar_key"
        case classe
        case emojiClasse = "emoji_classe"
        case nivel
        case xpAtual = "xp_atual"
        case xpProximoNivel = "xp_proximo_nivel"
        case moedas
        case streakDias = "streak_dias"
    }

    var avatarAsset: String {
        AvatarHelper.assetName(from: avatarKey)
    }

    var nomeExibicao: String {
        let nome = (nomeHeroi ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return nome.isEmpty ? "herói" : nome.lowercased()
    }
}

struct AcademiaResumoAPI: Codable, Equatable {
    var metaSemana: Int
    var feitos: Int
    var sequenciaTreinos: Int

    enum CodingKeys: String, CodingKey {
        case metaSemana = "meta_semana"
        case feitos
        case sequenciaTreinos = "sequencia_treinos"
    }
}

struct MissaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var icone: String
    var titulo: String
    var detalhe: String?
    var xp: Int
    var concluida: Bool
    var data: String?
    var ordem: Int?

    func asMissaoDoDia() -> MissaoDoDia {
        MissaoDoDia(
            id: id,
            icone: icone,
            titulo: titulo,
            detalhe: detalhe ?? "",
            xp: xp,
            concluida: concluida
        )
    }
}

struct DashboardAPI: Codable, Equatable {
    var perfil: PerfilAPI
    var missoes: [MissaoAPI]
    var missoesConcluidas: Int
    var missoesTotal: Int
    var xpHoje: Int
    var notificacoesNaoLidas: Int
    var academiaResumo: AcademiaResumoAPI

    enum CodingKeys: String, CodingKey {
        case perfil
        case missoes
        case missoesConcluidas = "missoes_concluidas"
        case missoesTotal = "missoes_total"
        case xpHoje = "xp_hoje"
        case notificacoesNaoLidas = "notificacoes_nao_lidas"
        case academiaResumo = "academia_resumo"
    }
}

struct NotificacaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var icone: String
    var titulo: String
    var mensagem: String
    var lida: Bool
    var quando: String
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, icone, titulo, mensagem, lida, quando
        case createdAt = "created_at"
    }

    func asItem() -> NotificacaoItem {
        NotificacaoItem(
            id: id,
            icone: icone,
            titulo: titulo,
            mensagem: mensagem,
            quando: quando,
            lida: lida
        )
    }
}

struct AcademiaDiaAPI: Codable, Equatable, Identifiable {
    let id: Int
    var diaChave: String
    var label: String
    var foco: String
    var isRest: Bool
    var concluido: Bool
    var ordem: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case diaChave = "dia_chave"
        case label, foco
        case isRest = "is_rest"
        case concluido, ordem
    }

    func asDiaSemana() -> DiaSemanaTreino {
        DiaSemanaTreino(
            id: id,
            label: label,
            foco: foco,
            concluido: concluido,
            isRest: isRest
        )
    }
}

struct AcademiaVolumeAPI: Codable, Equatable, Identifiable {
    let id: Int
    var diaChave: String
    var label: String
    var kg: Int

    enum CodingKeys: String, CodingKey {
        case id
        case diaChave = "dia_chave"
        case label, kg
    }

    func asVolume() -> VolumeDia {
        VolumeDia(id: String(id), label: label, kg: Double(kg))
    }
}

struct AcademiaTreinoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var foco: String
    var titulo: String
    var exercicios: Int
    var minutos: Int
    var xp: Int
    var diaChave: String?

    enum CodingKeys: String, CodingKey {
        case id, foco, titulo, exercicios, minutos, xp
        case diaChave = "dia_chave"
    }
}

struct AcademiaAPI: Codable, Equatable {
    var metaSemana: Int
    var feitos: Int
    var sequenciaTreinos: Int
    var semanaInicio: String
    var dias: [AcademiaDiaAPI]
    var volumes: [AcademiaVolumeAPI]
    var treinoHoje: AcademiaTreinoAPI?

    enum CodingKeys: String, CodingKey {
        case metaSemana = "meta_semana"
        case feitos
        case sequenciaTreinos = "sequencia_treinos"
        case semanaInicio = "semana_inicio"
        case dias, volumes
        case treinoHoje = "treino_hoje"
    }
}

enum AvatarHelper {
    static func assetName(from key: String) -> String {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return AvatarExplorador.guaraSerio.rawValue }
        if trimmed.hasPrefix("avatar_") { return trimmed }
        return "avatar_\(trimmed)"
    }

    static func apiKey(from asset: String) -> String {
        asset.replacingOccurrences(of: "avatar_", with: "")
    }
}
