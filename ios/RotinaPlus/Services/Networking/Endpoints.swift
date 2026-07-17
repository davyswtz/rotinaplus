import Foundation

enum Endpoints {
    case login
    case register
    case me
    case perfil
    case dashboard
    case missoes
    case toggleMissao(id: Int)
    case notificacoes
    case marcarNotificacaoLida(id: Int)
    case lerTodasNotificacoes
    case academia
    case toggleAcademiaDia(id: Int)
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
        case .dashboard:
            return "/api/v1/dashboard"
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
