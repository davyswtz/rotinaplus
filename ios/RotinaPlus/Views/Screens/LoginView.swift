import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("RotinaPlus")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("E-mail", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Senha", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            PrimaryButton(
                title: viewModel.isLoading ? "Entrando..." : "Entrar",
                action: {
                    Task { await viewModel.login() }
                }
            )
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
