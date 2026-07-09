import Foundation

class AuthManager {
    static let shared = AuthManager()

    private let tokenKey = "auth_token"

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    var isAuthenticated: Bool {
        token != nil
    }

    private init() {}

    func login(email: String, password: String) async throws {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }

        struct LoginResponse: Decodable {
            let success: Bool
            let data: LoginData?
        }

        struct LoginData: Decodable {
            let token: String
        }

        let response: LoginResponse = try await APIClient.shared.request(
            endpoint: .login,
            method: .post,
            body: LoginRequest(email: email, password: password)
        )

        guard let token = response.data?.token else {
            throw APIError.invalidResponse
        }

        self.token = token
    }

    func logout() {
        token = nil
    }
}
