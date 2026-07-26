import Foundation

enum Endpoints {
    case login
    case register
    case me
    case perfil
    case perfilStats(periodo: String)
    case amigos
    case adicionarAmigo
    case removerAmigo(id: Int)
    case dashboard
    case classes
    case missoes
    case toggleMissao(id: Int)
    case notificacoes
    case marcarNotificacaoLida(id: Int)
    case lerTodasNotificacoes
    case academia
    case toggleAcademiaDia(id: Int)
    case academiaExercicios(grupo: String?)
    case academiaHistorico
    case criarTreino
    case treino(id: Int)
    case atualizarTreino(id: Int)
    case excluirTreino(id: Int)
    case toggleTreinoExercicio(treinoId: Int, exercicioId: Int)
    case concluirTreino(id: Int)
    case registrarEsporte
    case excluirEsporteSessao(id: Int)
    case habitos(data: String?)
    case criarHabito
    case atualizarHabito(id: Int)
    case excluirHabito(id: Int)
    case toggleHabitoCheckin(id: Int)
    case atualizarHabitoNota(id: Int)
    case financas(mes: String?)
    case financasTransacoes
    case financasTransacao(id: Int)
    case financasMetas
    case financasMeta(id: Int)
    case pluggyConnectToken
    case pluggyVincular
    case pluggySincronizar
    case rotinas
    case rotina(id: Int)

    var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .register:
            return "/api/v1/auth/register"
        case .me:
            return "/api/v1/me"
        case .perfil:
            return "/api/v1/perfil"
        case .perfilStats(let periodo):
            return "/api/v1/perfil/stats?periodo=\(periodo)"
        case .amigos, .adicionarAmigo:
            return "/api/v1/amigos"
        case .removerAmigo(let id):
            return "/api/v1/amigos/\(id)"
        case .dashboard:
            return "/api/v1/dashboard"
        case .classes:
            return "/api/v1/classes"
        case .missoes:
            return "/api/v1/missoes"
        case .toggleMissao(let id):
            return "/api/v1/missoes/\(id)/toggle"
        case .notificacoes:
            return "/api/v1/notificacoes"
        case .marcarNotificacaoLida(let id):
            return "/api/v1/notificacoes/\(id)/lida"
        case .lerTodasNotificacoes:
            return "/api/v1/notificacoes/ler-todas"
        case .academia:
            return "/api/v1/academia"
        case .toggleAcademiaDia(let id):
            return "/api/v1/academia/dias/\(id)/toggle"
        case .academiaExercicios(let grupo):
            if let grupo, !grupo.isEmpty {
                let encoded = grupo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? grupo
                return "/api/v1/academia/exercicios?grupo=\(encoded)"
            }
            return "/api/v1/academia/exercicios"
        case .academiaHistorico:
            return "/api/v1/academia/treinos/historico"
        case .criarTreino:
            return "/api/v1/academia/treinos"
        case .treino(let id), .atualizarTreino(let id), .excluirTreino(let id):
            return "/api/v1/academia/treinos/\(id)"
        case .toggleTreinoExercicio(let treinoId, let exercicioId):
            return "/api/v1/academia/treinos/\(treinoId)/exercicios/\(exercicioId)/toggle"
        case .concluirTreino(let id):
            return "/api/v1/academia/treinos/\(id)/concluir"
        case .registrarEsporte:
            return "/api/v1/academia/esportes/sessoes"
        case .excluirEsporteSessao(let id):
            return "/api/v1/academia/esportes/sessoes/\(id)"
        case .habitos(let data):
            if let data, !data.isEmpty {
                return "/api/v1/habitos?data=\(data)"
            }
            return "/api/v1/habitos"
        case .criarHabito:
            return "/api/v1/habitos"
        case .atualizarHabito(let id):
            return "/api/v1/habitos/\(id)"
        case .excluirHabito(let id):
            return "/api/v1/habitos/\(id)"
        case .toggleHabitoCheckin(let id):
            return "/api/v1/habitos/\(id)/checkin"
        case .atualizarHabitoNota(let id):
            return "/api/v1/habitos/\(id)/nota"
        case .financas(let mes):
            if let mes, !mes.isEmpty {
                return "/api/v1/financas?mes=\(mes)"
            }
            return "/api/v1/financas"
        case .financasTransacoes:
            return "/api/v1/financas/transacoes"
        case .financasTransacao(let id):
            return "/api/v1/financas/transacoes/\(id)"
        case .financasMetas:
            return "/api/v1/financas/metas"
        case .financasMeta(let id):
            return "/api/v1/financas/metas/\(id)"
        case .pluggyConnectToken:
            return "/api/v1/financas/pluggy/connect-token"
        case .pluggyVincular:
            return "/api/v1/financas/pluggy/vincular"
        case .pluggySincronizar:
            return "/api/v1/financas/pluggy/sincronizar"
        case .rotinas:
            return "/api/v1/rotinas"
        case .rotina(let id):
            return "/api/v1/rotinas/\(id)"
        }
    }
}
