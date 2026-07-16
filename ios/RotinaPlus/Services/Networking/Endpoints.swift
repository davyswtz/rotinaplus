import Foundation

enum Endpoints {
    case login
    case me
    case dashboard
    case missoes
    case toggleMissao(id: Int)
    case notificacoes
    case marcarNotificacaoLida(id: Int)
    case lerTodasNotificacoes
    case academia
    case toggleAcademiaDia(id: Int)
    case rotinas
    case rotina(id: Int)

    var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .me:
            return "/api/v1/me"
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
        case .rotinas:
            return "/api/v1/rotinas"
        case .rotina(let id):
            return "/api/v1/rotinas/\(id)"
        }
    }
}
