import Foundation

// MARK: - Perfil / Dashboard (API)

struct PerfilAPI: Codable, Equatable {
    var nomeHeroi: String?
    var codigoAmigo: String?
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
        case codigoAmigo = "codigo_amigo"
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

    var codigoExibicao: String {
        let c = (codigoAmigo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return c.isEmpty ? "—" : c.uppercased()
    }
}

struct AmigoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var codigoAmigo: String?
    var nomeHeroi: String?
    var avatarKey: String
    var classe: String
    var emojiClasse: String
    var nivel: Int

    enum CodingKeys: String, CodingKey {
        case id, classe, nivel
        case codigoAmigo = "codigo_amigo"
        case nomeHeroi = "nome_heroi"
        case avatarKey = "avatar_key"
        case emojiClasse = "emoji_classe"
    }

    var avatarAsset: String {
        AvatarHelper.assetName(from: avatarKey)
    }

    var nomeExibicao: String {
        let nome = (nomeHeroi ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return nome.isEmpty ? (codigoAmigo ?? "herói") : nome.lowercased()
    }
}

struct AmigosListaAPI: Codable, Equatable {
    var amigos: [AmigoAPI]
    var total: Int
}

struct ConviteAmigoRespostaAPI: Codable, Equatable {
    var amizadeId: Int
    var status: String

    enum CodingKeys: String, CodingKey {
        case amizadeId = "amizade_id"
        case status
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

struct HabitosResumoAPI: Codable, Equatable {
    var concluidos: Int
    var total: Int
    var streakGeral: Int
    var percentual: Int

    enum CodingKeys: String, CodingKey {
        case concluidos, total, percentual
        case streakGeral = "streak_geral"
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
    var habitosResumo: HabitosResumoAPI?

    enum CodingKeys: String, CodingKey {
        case perfil, missoes
        case missoesConcluidas = "missoes_concluidas"
        case missoesTotal = "missoes_total"
        case xpHoje = "xp_hoje"
        case notificacoesNaoLidas = "notificacoes_nao_lidas"
        case academiaResumo = "academia_resumo"
        case habitosResumo = "habitos_resumo"
    }
}

struct NotificacaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var icone: String
    var titulo: String
    var mensagem: String
    var tipo: String?
    var referenciaId: Int?
    var payload: [String: String]?
    var lida: Bool
    var quando: String
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, icone, titulo, mensagem, tipo, lida, quando, payload
        case referenciaId = "referencia_id"
        case createdAt = "created_at"
    }

    /// Payload da API pode ter números; decodifica de forma flexível.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        icone = try c.decode(String.self, forKey: .icone)
        titulo = try c.decode(String.self, forKey: .titulo)
        mensagem = try c.decode(String.self, forKey: .mensagem)
        tipo = try c.decodeIfPresent(String.self, forKey: .tipo)
        referenciaId = try c.decodeIfPresent(Int.self, forKey: .referenciaId)
        lida = try c.decode(Bool.self, forKey: .lida)
        quando = try c.decode(String.self, forKey: .quando)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)

        if let dict = try? c.decode([String: FlexibleJSONValue].self, forKey: .payload) {
            var flat: [String: String] = [:]
            dict.forEach { key, value in
                flat[key] = value.stringValue
            }
            payload = flat
        } else {
            payload = nil
        }
    }

    var isConviteAmigo: Bool { tipo == "convite_amigo" }
    var amizadeId: Int? { referenciaId }

    func asItem() -> NotificacaoItem {
        NotificacaoItem(
            id: id,
            icone: icone,
            titulo: titulo,
            mensagem: mensagem,
            quando: quando,
            lida: lida,
            tipo: tipo,
            referenciaId: referenciaId
        )
    }
}

private enum FlexibleJSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let v = try? c.decode(String.self) { self = .string(v); return }
        if let v = try? c.decode(Int.self) { self = .int(v); return }
        if let v = try? c.decode(Double.self) { self = .double(v); return }
        if let v = try? c.decode(Bool.self) { self = .bool(v); return }
        self = .null
    }

    var stringValue: String {
        switch self {
        case .string(let s): return s
        case .int(let i): return String(i)
        case .double(let d): return String(Int(d))
        case .bool(let b): return b ? "1" : "0"
        case .null: return ""
        }
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

struct TreinoExercicioPayload: Encodable, Equatable {
    let exercicioChave: String
    let series: Int
    let reps: Int
    let cargaKg: Int

    enum CodingKeys: String, CodingKey {
        case series, reps
        case exercicioChave = "exercicio_chave"
        case cargaKg = "carga_kg"
    }
}

struct AcademiaTreinoExercicioAPI: Codable, Equatable {
    let id: Int?
    var exercicioChave: String
    var nome: String
    var icone: String
    var grupo: String
    var series: Int
    var reps: Int
    var cargaKg: Int
    var ordem: Int?
    var concluido: Bool?

    var stableId: String { "\(id ?? 0)-\(exercicioChave)-\(ordem ?? 0)" }

    enum CodingKeys: String, CodingKey {
        case id, nome, icone, grupo, series, reps, ordem, concluido
        case exercicioChave = "exercicio_chave"
        case cargaKg = "carga_kg"
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
    var ativo: Bool?
    var concluidoEm: String?
    var volumeKg: Int?
    var itens: [AcademiaTreinoExercicioAPI]?

    enum CodingKeys: String, CodingKey {
        case id, foco, titulo, exercicios, minutos, xp, ativo, itens
        case diaChave = "dia_chave"
        case concluidoEm = "concluido_em"
        case volumeKg = "volume_kg"
    }
}

struct ExercicioCatalogoAPI: Codable, Equatable, Identifiable {
    var chave: String
    var nome: String
    var icone: String
    var grupo: String
    var seriesPadrao: Int
    var repsPadrao: Int
    var cargaPadrao: Int

    var id: String { chave }

    enum CodingKeys: String, CodingKey {
        case chave, nome, icone, grupo
        case seriesPadrao = "series_padrao"
        case repsPadrao = "reps_padrao"
        case cargaPadrao = "carga_padrao"
    }
}

struct ExercicioCatalogoDataAPI: Codable, Equatable {
    var focos: [String]
    var exercicios: [ExercicioCatalogoAPI]
}

struct AcademiaAPI: Codable, Equatable {
    var metaSemana: Int
    var feitos: Int
    var sequenciaTreinos: Int
    var semanaInicio: String
    var dias: [AcademiaDiaAPI]
    var volumes: [AcademiaVolumeAPI]
    var treinoHoje: AcademiaTreinoAPI?
    var focos: [String]?
    var esportes: [EsporteCatalogoAPI]?
    var esporteResumo: EsporteResumoAPI?
    var esporteSessoes: [EsporteSessaoAPI]?

    enum CodingKeys: String, CodingKey {
        case metaSemana = "meta_semana"
        case feitos
        case sequenciaTreinos = "sequencia_treinos"
        case semanaInicio = "semana_inicio"
        case dias, volumes, focos, esportes
        case treinoHoje = "treino_hoje"
        case esporteResumo = "esporte_resumo"
        case esporteSessoes = "esporte_sessoes"
    }
}

struct EsporteCatalogoAPI: Codable, Equatable, Identifiable {
    var chave: String
    var nome: String
    var icone: String
    var descricao: String
    var minutosPadrao: Int
    var usaDistancia: Bool

    var id: String { chave }

    enum CodingKeys: String, CodingKey {
        case chave, nome, icone, descricao
        case minutosPadrao = "minutos_padrao"
        case usaDistancia = "usa_distancia"
    }

    static let fallback: [EsporteCatalogoAPI] = [
        .init(chave: "corrida", nome: "Corrida", icone: "🏃", descricao: "Corrida ao ar livre ou esteira", minutosPadrao: 30, usaDistancia: true),
        .init(chave: "natacao", nome: "Natação", icone: "🏊", descricao: "Piscina ou águas abertas", minutosPadrao: 40, usaDistancia: true),
        .init(chave: "volei", nome: "Vôlei", icone: "🏐", descricao: "Quadra ou praia", minutosPadrao: 60, usaDistancia: false),
        .init(chave: "futebol", nome: "Futebol", icone: "⚽", descricao: "Campo, society ou futsal", minutosPadrao: 60, usaDistancia: false),
        .init(chave: "basquete", nome: "Basquete", icone: "🏀", descricao: "Quadra ou streetball", minutosPadrao: 45, usaDistancia: false),
        .init(chave: "ciclismo", nome: "Ciclismo", icone: "🚴", descricao: "Bike de rua ou indoor", minutosPadrao: 45, usaDistancia: true),
        .init(chave: "tenis", nome: "Tênis", icone: "🎾", descricao: "Simples ou duplas", minutosPadrao: 60, usaDistancia: false),
        .init(chave: "caminhada", nome: "Caminhada", icone: "🚶", descricao: "Passeio ativo", minutosPadrao: 30, usaDistancia: true),
        .init(chave: "yoga", nome: "Yoga", icone: "🧘", descricao: "Mobilidade e respiração", minutosPadrao: 30, usaDistancia: false),
        .init(chave: "artes_marciais", nome: "Artes marciais", icone: "🥋", descricao: "Jiu-jitsu, judô, boxe…", minutosPadrao: 60, usaDistancia: false),
        .init(chave: "crossfit", nome: "CrossFit", icone: "💥", descricao: "WOD e condicionamento", minutosPadrao: 45, usaDistancia: false),
        .init(chave: "surf", nome: "Surf", icone: "🏄", descricao: "Mar ou piscina de ondas", minutosPadrao: 90, usaDistancia: false),
    ]
}

struct EsporteResumoAPI: Codable, Equatable {
    var totalSemana: Int
    var minutosSemana: Int
    var xpSemana: Int

    enum CodingKeys: String, CodingKey {
        case totalSemana = "total_semana"
        case minutosSemana = "minutos_semana"
        case xpSemana = "xp_semana"
    }
}

struct EsporteSessaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var esporteChave: String
    var icone: String
    var nome: String
    var minutos: Int
    var distanciaMetros: Int?
    var xp: Int
    var data: String?
    var nota: String?

    enum CodingKeys: String, CodingKey {
        case id, icone, nome, minutos, xp, data, nota
        case esporteChave = "esporte_chave"
        case distanciaMetros = "distancia_metros"
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
    var origem: String?

    enum CodingKeys: String, CodingKey {
        case id, tipo, categoria, titulo, icone, data, origem
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

struct FinancasConexaoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var provider: String
    var itemId: String?
    var connectorName: String?
    var status: String
    var lastSyncAt: String?

    enum CodingKeys: String, CodingKey {
        case id, provider, status
        case itemId = "item_id"
        case connectorName = "connector_name"
        case lastSyncAt = "last_sync_at"
    }
}

struct FinancasPluggyAPI: Codable, Equatable {
    var configured: Bool
    var localSandbox: Bool
    var conexoes: [FinancasConexaoAPI]

    enum CodingKeys: String, CodingKey {
        case configured, conexoes
        case localSandbox = "local_sandbox"
    }

    var temConexao: Bool { !conexoes.isEmpty }
}

struct PluggyConnectTokenAPI: Codable, Equatable {
    var mode: String
    var accessToken: String
    var includeSandbox: Bool?

    enum CodingKeys: String, CodingKey {
        case mode
        case accessToken = "access_token"
        case includeSandbox = "include_sandbox"
    }
}

struct PluggySyncResultAPI: Codable, Equatable {
    var importadas: Int
    var atualizadas: Int
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
    var pluggy: FinancasPluggyAPI?

    enum CodingKeys: String, CodingKey {
        case meses, distribuicao, recentes, transacoes, metas, categorias, pluggy
        case anoMes = "ano_mes"
        case mesLabel = "mes_label"
        case saldoCentavos = "saldo_centavos"
        case receitaCentavos = "receita_centavos"
        case gastosCentavos = "gastos_centavos"
        case serieMensal = "serie_mensal"
    }
}

// MARK: - Diário / Hábitos

struct HabitoAPI: Codable, Equatable, Identifiable {
    let id: Int
    var icone: String
    var titulo: String
    var detalhe: String?
    var area: String
    var frequencia: String
    var diasSemana: [Int]?
    var xp: Int
    var ativo: Bool?
    var ordem: Int?

    enum CodingKeys: String, CodingKey {
        case id, icone, titulo, detalhe, area, frequencia, xp, ativo, ordem
        case diasSemana = "dias_semana"
    }
}

struct HabitoCheckinAPI: Codable, Equatable, Identifiable {
    let id: Int
    var habitoId: Int
    var data: String?
    var concluida: Bool
    var concluidaEm: String?
    var humor: Int?
    var nota: String?

    enum CodingKeys: String, CodingKey {
        case id, data, concluida, humor, nota
        case habitoId = "habito_id"
        case concluidaEm = "concluida_em"
    }
}

struct HabitoSemanaDiaAPI: Codable, Equatable, Identifiable {
    var data: String
    var label: String
    var concluidos: Int
    var total: Int
    var percentual: Int

    var id: String { data }
}

struct HabitoSugestaoAPI: Codable, Equatable {
    var icone: String
    var titulo: String
    var detalhe: String
    var area: String
}

struct HabitoItemJournalAPI: Codable, Equatable, Identifiable {
    var habito: HabitoAPI
    var checkin: HabitoCheckinAPI?
    var concluida: Bool
    var streak: Int

    var id: Int { habito.id }
}

struct HabitoJournalResumoAPI: Codable, Equatable {
    var concluidos: Int
    var total: Int
    var percentual: Int
    var streakGeral: Int
    var xpHoje: Int

    enum CodingKeys: String, CodingKey {
        case concluidos, total, percentual
        case streakGeral = "streak_geral"
        case xpHoje = "xp_hoje"
    }
}

struct HabitoJournalAPI: Codable, Equatable {
    var data: String
    var hoje: String
    var resumo: HabitoJournalResumoAPI
    var semana: [HabitoSemanaDiaAPI]
    var itens: [HabitoItemJournalAPI]
    var sugestoes: [HabitoSugestaoAPI]
    var areas: [String]
}

struct HabitoToggleResultAPI: Codable, Equatable {
    var habito: HabitoAPI
    var checkin: HabitoCheckinAPI
    var concluida: Bool
    var streak: Int
    var bonusDia: HabitoBonusDiaAPI?

    enum CodingKeys: String, CodingKey {
        case habito, checkin, concluida, streak
        case bonusDia = "bonus_dia"
    }
}

struct HabitoBonusDiaAPI: Codable, Equatable {
    var completo: Bool
    var moedas: Int
    var streakDias: Int

    enum CodingKeys: String, CodingKey {
        case completo, moedas
        case streakDias = "streak_dias"
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

// MARK: - Perfil stats

struct PerfilStatsAPI: Codable, Equatable {
    var periodo: String
    var inicio: String
    var fim: String
    var perfil: PerfilAPI
    var totais: PerfilTotaisAPI
    var serie: [PerfilSerieDiaAPI]
    var porArea: PerfilAreasAPI
    var nivel: PerfilNivelAPI

    enum CodingKeys: String, CodingKey {
        case periodo, inicio, fim, perfil, totais, serie, nivel
        case porArea = "por_area"
    }
}

struct PerfilTotaisAPI: Codable, Equatable {
    var acertos: Int
    var falhas: Int
    var taxaSucesso: Int
    var xpGanho: Int
    var diasCompletos: Int
    var streakAtual: Int
    var sequenciaTreinos: Int

    enum CodingKeys: String, CodingKey {
        case acertos, falhas
        case taxaSucesso = "taxa_sucesso"
        case xpGanho = "xp_ganho"
        case diasCompletos = "dias_completos"
        case streakAtual = "streak_atual"
        case sequenciaTreinos = "sequencia_treinos"
    }
}

struct PerfilSerieDiaAPI: Codable, Equatable, Identifiable {
    var data: String
    var label: String
    var acertos: Int
    var falhas: Int
    var taxa: Int
    var xp: Int

    var id: String { data }
}

struct PerfilAreaStatsAPI: Codable, Equatable {
    var acertos: Int?
    var falhas: Int?
    var taxa: Int?
    var sessoes: Int?
    var minutos: Int?
    var xp: Int?
}

struct PerfilAreasAPI: Codable, Equatable {
    var missoes: PerfilAreaStatsAPI
    var habitos: PerfilAreaStatsAPI
    var academia: PerfilAreaStatsAPI
    var esportes: PerfilAreaStatsAPI
}

struct PerfilNivelAPI: Codable, Equatable {
    var atual: Int
    var xpAtual: Int
    var xpProximo: Int
    var progresso: Double
    var moedas: Int

    enum CodingKeys: String, CodingKey {
        case atual, progresso, moedas
        case xpAtual = "xp_atual"
        case xpProximo = "xp_proximo"
    }
}
