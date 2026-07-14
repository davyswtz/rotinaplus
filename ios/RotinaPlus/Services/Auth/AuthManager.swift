import Foundation

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private static let tokenKey = "auth_token"

    @Published private(set) var isAuthenticated: Bool

    nonisolated var token: String? {
        UserDefaults.standard.string(forKey: Self.tokenKey)
    }

    private init() {
        isAuthenticated = UserDefaults.standard.string(forKey: Self.tokenKey) != nil
    }

    func login(email: String, password: String) async throws {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }

        struct LoginResponse: Decodable {
            let user: AuthUser
            let token: String
        }

        let response: LoginResponse = try await APIClient.shared.request(
            endpoint: .login,
            method: .post,
            body: LoginRequest(email: email, password: password)
        )

        UserDefaults.standard.set(response.token, forKey: Self.tokenKey)
        isAuthenticated = true
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: Self.tokenKey)
        isAuthenticated = false
    }

    /// Só para preview/teste local sem API.
    func entrarComoConvidado() {
        UserDefaults.standard.set("debug_preview_token", forKey: Self.tokenKey)
        isAuthenticated = true
    }
}

struct AuthUser: Decodable {
    let id: Int
    let name: String
    let email: String
}
