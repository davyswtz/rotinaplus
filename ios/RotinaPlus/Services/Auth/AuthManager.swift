import Foundation

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private static let tokenKey = "auth_token"
    private static let nomeHeroiKey = "nome_heroi"
    private static let avatarKey = "avatar_selecionado"
    private static let classeKey = "classe_selecionada"
    private static let classeNomeKey = "classe_nome"
    private static let emojiClasseKey = "emoji_classe"

    @Published private(set) var isAuthenticated: Bool
    /// Conta nova: força Bem-vindo → avatar → nome → Home.
    @Published private(set) var forceOnboarding: Bool = false

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

        struct AuthResponse: Decodable {
            let user: AuthUser
            let token: String
        }

        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: .login,
            method: .post,
            body: LoginRequest(email: email, password: password)
        )

        forceOnboarding = false
        persistSession(token: response.token)
    }

    func register(
        name: String,
        email: String,
        password: String,
        passwordConfirmation: String
    ) async throws {
        struct RegisterRequest: Encodable {
            let name: String
            let email: String
            let password: String
            let passwordConfirmation: String

            enum CodingKeys: String, CodingKey {
                case name, email, password
                case passwordConfirmation = "password_confirmation"
            }
        }

        struct AuthResponse: Decodable {
            let user: AuthUser
            let token: String
        }

        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: .register,
            method: .post,
            body: RegisterRequest(
                name: name,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
        )

        clearOnboardingLocalState()
        forceOnboarding = true
        persistSession(token: response.token)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: Self.tokenKey)
        forceOnboarding = false
        isAuthenticated = false
    }

    func markOnboardingComplete() {
        forceOnboarding = false
    }

    private func clearOnboardingLocalState() {
        UserDefaults.standard.removeObject(forKey: Self.nomeHeroiKey)
        UserDefaults.standard.removeObject(forKey: Self.avatarKey)
        UserDefaults.standard.removeObject(forKey: Self.classeKey)
        UserDefaults.standard.removeObject(forKey: Self.classeNomeKey)
        UserDefaults.standard.removeObject(forKey: Self.emojiClasseKey)
    }

    private func persistSession(token: String) {
        UserDefaults.standard.set(token, forKey: Self.tokenKey)
        isAuthenticated = true
    }
}

struct AuthUser: Decodable {
    let id: Int
    let name: String
    let email: String
}
