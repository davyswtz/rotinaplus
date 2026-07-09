import Foundation

enum Endpoints {
    case login
    case rotinas
    case rotina(id: Int)

    var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .rotinas:
            return "/api/v1/rotinas"
        case .rotina(let id):
            return "/api/v1/rotinas/\(id)"
        }
    }
}
