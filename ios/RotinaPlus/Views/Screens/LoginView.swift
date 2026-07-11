import SwiftUI

// MARK: - Cores da tela de login
// Paleta espelhada de TelaBemVindo.swift e do theme/colors.ts (Android).
private enum CoresLogin {
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

// MARK: - Tela de Login (iOS)
// Layout espelhado do LoginScreen.tsx no Android.
// Apenas UI + LoginViewModel; botões sociais são placeholders até integrar SDKs.
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            // MARK: Fundo
            // Gradiente roxo escuro — mesma identidade visual do onboarding.
            LinearGradient(
                colors: [CoresLogin.fundoSuperior, CoresLogin.fundoInferior],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // MARK: Conteúdo rolável (evita sobreposição do teclado)
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: Cabeçalho — mascote + título + subtítulo
                    cabecalho
                        .padding(.top, 32)
                        .padding(.bottom, 32)

                    // MARK: Formulário — e-mail e senha
                    formulario
                        .padding(.bottom, 8)

                    // MARK: Mensagem de erro da API
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(CoresLogin.erro)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }

                    // MARK: Botão principal "Entrar"
                    botaoEntrar
                        .padding(.bottom, viewModel.isLoading ? 12 : 0)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(CoresLogin.roxoPrimario)
                            .padding(.bottom, 8)
                    }

                    // MARK: Divisor "ou continue com"
                    divisorSocial
                        .padding(.vertical, 24)

                    // MARK: Botões de login social
                    botoesSociais
                        .padding(.bottom, 24)

                    // MARK: Rodapé — link para criar conta
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
            // TODO: substituir por Image("guara") quando o asset estiver no projeto.
            Image(systemName: "pawprint.fill")
                .font(.system(size: 56))
                .foregroundStyle(CoresLogin.laranjaMascote)

            Text("Entrar no RotinaPlus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Continue sua aventura RPG e evolua seus hábitos diários.")
                .font(.subheadline)
                .foregroundStyle(CoresLogin.textoSecundario)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: Formulário
    private var formulario: some View {
        VStack(alignment: .leading, spacing: 16) {
            campoTexto(
                rotulo: "E-mail",
                placeholder: "seu@email.com",
                texto: $viewModel.email,
                tipoConteudo: .emailAddress,
                teclado: .emailAddress,
                seguro: false
            )

            campoTexto(
                rotulo: "Senha",
                placeholder: "••••••••",
                texto: $viewModel.password,
                tipoConteudo: .password,
                teclado: .default,
                seguro: true
            )

            // MARK: Link esqueci senha
            Button {
                // TODO: navegar para tela de recuperação de senha
            } label: {
                Text("Esqueci minha senha")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(CoresLogin.roxoPrimario)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    // MARK: Campo de texto reutilizável
    private func campoTexto(
        rotulo: String,
        placeholder: String,
        texto: Binding<String>,
        tipoConteudo: UITextContentType,
        teclado: UIKeyboardType,
        seguro: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(CoresLogin.textoSecundario)
                .padding(.leading, 4)

            Group {
                if seguro {
                    SecureField(placeholder, text: texto)
                } else {
                    TextField(placeholder, text: texto)
                        .textContentType(tipoConteudo)
                        .keyboardType(teclado)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(CoresLogin.campoFundo)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CoresLogin.campoBorda, lineWidth: 1)
            )
            .foregroundStyle(.white)
            .tint(CoresLogin.roxoPrimario)
        }
    }

    // MARK: Botão "Entrar"
    private var botaoEntrar: some View {
        Button {
            Task { await viewModel.login() }
        } label: {
            Text(viewModel.isLoading ? "Entrando..." : "Entrar")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.isLoading
                        ? CoresLogin.roxoPrimario.opacity(0.45)
                        : CoresLogin.roxoPrimario
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
                .fill(CoresLogin.campoBorda)
                .frame(height: 1)

            Text("ou continue com")
                .font(.caption)
                .foregroundStyle(CoresLogin.textoSecundario)
                .fixedSize()

            Rectangle()
                .fill(CoresLogin.campoBorda)
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

    // MARK: Botão social reutilizável
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
            .background(CoresLogin.botaoSocialFundo)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(CoresLogin.botaoSocialBorda, lineWidth: 1)
            )
            .foregroundStyle(.white)
        }
    }

    // MARK: Rodapé
    private var rodape: some View {
        HStack(spacing: 4) {
            Text("Ainda não tem conta?")
                .font(.subheadline)
                .foregroundStyle(CoresLogin.textoSecundario)

            Button {
                // TODO: navegar para tela de cadastro
            } label: {
                Text("Criar conta")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(CoresLogin.roxoPrimario)
            }
        }
    }
}

#Preview {
    LoginView()
}
