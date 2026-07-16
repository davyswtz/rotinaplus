import Foundation

@MainActor
class CadastroViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authManager = AuthManager.shared

    func register() async {
        let nome = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTrim = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nome.isEmpty, !emailTrim.isEmpty, !password.isEmpty, !passwordConfirmation.isEmpty else {
            errorMessage = "Preencha todos os campos."
            return
        }

        guard password == passwordConfirmation else {
            errorMessage = "A confirmação de senha não confere."
            return
        }

        guard password.count >= 8 else {
            errorMessage = "A senha deve ter pelo menos 8 caracteres."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authManager.register(
                name: nome,
                email: emailTrim,
                password: password,
                passwordConfirmation: passwordConfirmation
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
