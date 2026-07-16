import SwiftUI

// MARK: - Cores da tela de cadastro (mesma paleta do login)
private enum CoresCadastro {
    static let fundoSuperior = Color(red: 0.10, green: 0.06, blue: 0.18)
    static let fundoInferior = Color(red: 0.05, green: 0.03, blue: 0.10)
    static let roxoPrimario = Color(red: 0.48, green: 0.26, blue: 0.96)
    static let textoSecundario = Color.white.opacity(0.65)
    static let textoPlaceholder = Color.white.opacity(0.40)
    static let campoFundo = Color.white.opacity(0.08)
    static let campoBorda = Color.white.opacity(0.18)
    static let laranjaMascote = Color(red: 1.0, green: 0.55, blue: 0.20)
    static let erro = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let botaoSocialFundo = Color.white.opacity(0.10)
    static let botaoSocialBorda = Color.white.opacity(0.15)
}

// MARK: - Tela de Criar Conta (iOS)
// Layout espelhado do LoginView.swift / RegisterScreen.tsx (Android).
struct CadastroView: View {
    var onVoltar: () -> Void = {}

    @StateObject private var viewModel = CadastroViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CoresCadastro.fundoSuperior, CoresCadastro.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    cabecalho
                        .padding(.top, 32)
                        .padding(.bottom, 32)

                    formulario
                        .padding(.bottom, 8)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(CoresCadastro.erro)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }

                    botaoCriarConta
                        .padding(.bottom, viewModel.isLoading ? 12 : 0)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(CoresCadastro.roxoPrimario)
                            .padding(.bottom, 8)
                    }

                    divisorSocial
                        .padding(.vertical, 24)

                    botoesSociais
                        .padding(.bottom, 24)

                    rodape
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Cabeçalho
    private var cabecalho: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 56))
                .foregroundStyle(CoresCadastro.laranjaMascote)

            Text("Criar conta no RotinaPlus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Comece sua aventura RPG e transforme hábitos em XP.")
                .font(.subheadline)
                .foregroundStyle(CoresCadastro.textoSecundario)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: Formulário
    private var formulario: some View {
        VStack(alignment: .leading, spacing: 16) {
            campoTexto(
                rotulo: "Nome",
                placeholder: "Seu nome",
                texto: $viewModel.name,
                tipoConteudo: .name,
                teclado: .default,
                seguro: false,
                autocapitalizacao: .words
            )

            campoTexto(
                rotulo: "E-mail",
                placeholder: "seu@email.com",
                texto: $viewModel.email,
                tipoConteudo: .emailAddress,
                teclado: .emailAddress,
                seguro: false,
                autocapitalizacao: .never
            )

            campoTexto(
                rotulo: "Senha",
                placeholder: "Mínimo 8 caracteres",
                texto: $viewModel.password,
                tipoConteudo: .newPassword,
                teclado: .default,
                seguro: true,
                autocapitalizacao: .never
            )

            campoTexto(
                rotulo: "Confirmar senha",
                placeholder: "Repita a senha",
                texto: $viewModel.passwordConfirmation,
                tipoConteudo: .newPassword,
                teclado: .default,
                seguro: true,
                autocapitalizacao: .never
            )
        }
    }

    // MARK: Campo de texto reutilizável
    private func campoTexto(
        rotulo: String,
        placeholder: String,
        texto: Binding<String>,
        tipoConteudo: UITextContentType,
        teclado: UIKeyboardType,
        seguro: Bool,
        autocapitalizacao: TextInputAutocapitalization
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(CoresCadastro.textoSecundario)
                .padding(.leading, 4)

            Group {
                if seguro {
                    SecureField(placeholder, text: texto)
                        .textContentType(tipoConteudo)
                } else {
                    TextField(placeholder, text: texto)
                        .textContentType(tipoConteudo)
                        .keyboardType(teclado)
                        .textInputAutocapitalization(autocapitalizacao)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(CoresCadastro.campoFundo)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CoresCadastro.campoBorda, lineWidth: 1)
            )
            .foregroundStyle(.white)
            .tint(CoresCadastro.roxoPrimario)
        }
    }

    // MARK: Botão "Criar conta"
    private var botaoCriarConta: some View {
        Button {
            Task { await viewModel.register() }
        } label: {
            Text(viewModel.isLoading ? "Criando conta..." : "Criar conta")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.isLoading
                        ? CoresCadastro.roxoPrimario.opacity(0.45)
                        : CoresCadastro.roxoPrimario
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: Divisor social
    private var divisorSocial: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(CoresCadastro.campoBorda)
                .frame(height: 1)

            Text("ou continue com")
                .font(.caption)
                .foregroundStyle(CoresCadastro.textoSecundario)
                .fixedSize()

            Rectangle()
                .fill(CoresCadastro.campoBorda)
                .frame(height: 1)
        }
    }

    // MARK: Botões sociais
    private var botoesSociais: some View {
        VStack(spacing: 12) {
            botaoSocial(titulo: "Continuar com Google", icone: "G") {
                // TODO: integrar Google Sign-In e enviar token para /api/v1/auth/social
            }

            botaoSocial(titulo: "Continuar com Apple", icone: "apple.logo", sistema: true) {
                // TODO: integrar Sign in with Apple e enviar token para /api/v1/auth/social
            }
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.5 : 1)
    }

    private func botaoSocial(
        titulo: String,
        icone: String,
        sistema: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if sistema {
                    Image(systemName: icone)
                        .font(.body)
                } else {
                    Text(icone)
                        .font(.body)
                        .fontWeight(.bold)
                }

                Text(titulo)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(CoresCadastro.botaoSocialFundo)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(CoresCadastro.botaoSocialBorda, lineWidth: 1)
            )
            .foregroundStyle(.white)
        }
    }

    // MARK: Rodapé
    private var rodape: some View {
        HStack(spacing: 4) {
            Text("Já tem conta?")
                .font(.subheadline)
                .foregroundStyle(CoresCadastro.textoSecundario)

            Button {
                onVoltar()
            } label: {
                Text("Entrar")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(CoresCadastro.roxoPrimario)
            }
        }
    }
}

#Preview {
    CadastroView()
}
