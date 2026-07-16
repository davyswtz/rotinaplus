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

// MARK: - Finanças

struct FinancasMesAPI: Codable, Equatable, Identifiable {
    var anoMes: String
    var label: String
    var curto: String

    var id: String { anoMes }

    enum CodingKeys: String, CodingKey {
        case anoMes = "ano_mes"
        case label, curto
    }
}

struct FinancasSerieAPI: Codable, Equatable, Identifiable {
    var anoMes: String
    var curto: String
    var receitaCentavos: Int
    var gastosCentavos: Int
    var saldoCentavos: Int

    var id: String { anoMes }

    enum CodingKeys: String, CodingKey {
        case anoMes = "ano_mes"
        case curto
        case receitaCentavos = "receita_centavos"
        case gastosCentavos = "gastos_centavos"
        case saldoCentavos = "saldo_centavos"
    }
}

struct FinancasDistribuicaoAPI: Codable, Equatable, Identifiable {
    var categoria: String
    var nome: String
    var cor: String
    var valorCentavos: Int
    var percentual: Double

    var id: String { categoria }

    enum CodingKeys: String, CodingKey {
        case categoria, nome, cor
        case valorCentavos = "valor_centavos"
        case percentual
    }
}

struct FinancasTransacaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var tipo: String
    var categoria: String
    var categoriaNome: String
    var categoriaCor: String
    var titulo: String
    var icone: String
    var valorCentavos: Int
    var data: String

    enum CodingKeys: String, CodingKey {
        case id, tipo, categoria, titulo, icone, data
        case categoriaNome = "categoria_nome"
        case categoriaCor = "categoria_cor"
        case valorCentavos = "valor_centavos"
    }

    var isReceita: Bool { tipo == "receita" }
}

struct FinancasMetaAPI: Codable, Equatable, Identifiable {
    let id: Int
    var titulo: String
    var icone: String
    var categoria: String?
    var valorAlvoCentavos: Int
    var valorAtualCentavos: Int
    var percentual: Double

    enum CodingKeys: String, CodingKey {
        case id, titulo, icone, categoria, percentual
        case valorAlvoCentavos = "valor_alvo_centavos"
        case valorAtualCentavos = "valor_atual_centavos"
    }
}

struct FinancasCategoriaAPI: Codable, Equatable, Identifiable {
    var chave: String
    var nome: String
    var cor: String
    var icone: String

    var id: String { chave }
}

struct FinancasCategoriasAPI: Codable, Equatable {
    var despesas: [FinancasCategoriaAPI]
    var receita: FinancasCategoriaAPI
}

struct FinancasAPI: Codable, Equatable {
    var anoMes: String
    var mesLabel: String
    var meses: [FinancasMesAPI]
    var saldoCentavos: Int
    var receitaCentavos: Int
    var gastosCentavos: Int
    var serieMensal: [FinancasSerieAPI]
    var distribuicao: [FinancasDistribuicaoAPI]
    var recentes: [FinancasTransacaoAPI]
    var transacoes: [FinancasTransacaoAPI]
    var metas: [FinancasMetaAPI]
    var categorias: FinancasCategoriasAPI

    enum CodingKeys: String, CodingKey {
        case meses, distribuicao, recentes, transacoes, metas, categorias
        case anoMes = "ano_mes"
        case mesLabel = "mes_label"
        case saldoCentavos = "saldo_centavos"
        case receitaCentavos = "receita_centavos"
        case gastosCentavos = "gastos_centavos"
        case serieMensal = "serie_mensal"
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
