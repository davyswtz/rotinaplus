import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    #if DEBUG
    @Published var email: String = "davy@teste.com"
    @Published var password: String = "senha123"
    #else
    @Published var email: String = ""
    @Published var password: String = ""
    #endif
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authManager = AuthManager.shared

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha e-mail e senha."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
