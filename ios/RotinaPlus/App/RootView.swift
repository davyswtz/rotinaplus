import SwiftUI

private enum OnboardingFase {
    case bemVindo
    case escolhaClasse
    case escolhaAvatar
    case nomeHeroi
    case home
}

private enum AuthGuestRoute: Hashable {
    case cadastro
}

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var onboarding: OnboardingFase = Self.faseInicial
    @State private var guestPath = NavigationPath()
    @State private var classeSelecionada: ClasseHeroi = .guerreiro
    @State private var avatarSelecionado: AvatarExplorador = .guaraSerio
    @State private var mostrandoLoading = true

    private static var faseInicial: OnboardingFase {
        let nome = UserDefaults.standard.string(forKey: "nome_heroi")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (nome?.isEmpty == false) ? .home : .bemVindo
    }

    var body: some View {
        Group {
            if mostrandoLoading {
                TelaLoading()
            } else if authManager.isAuthenticated {
                switch onboarding {
                case .bemVindo:
                    TelaBemVindo {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            onboarding = .escolhaClasse
                        }
                    }
                case .escolhaClasse:
                    TelaEscolhaClasse(
                        onContinuar: { classe in
                            classeSelecionada = classe
                            UserDefaults.standard.set(classe.rawValue, forKey: "classe_selecionada")
                            UserDefaults.standard.set(classe.nome, forKey: "classe_nome")
                            UserDefaults.standard.set(classe.emoji, forKey: "emoji_classe")
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .escolhaAvatar
                            }
                        },
                        onVoltar: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .bemVindo
                            }
                        }
                    )
                case .escolhaAvatar:
                    TelaEscolhaAvatar(
                        onContinuar: { avatar in
                            avatarSelecionado = avatar
                            UserDefaults.standard.set(avatar.rawValue, forKey: "avatar_selecionado")
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .nomeHeroi
                            }
                        },
                        onVoltar: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .escolhaClasse
                            }
                        }
                    )
                case .nomeHeroi:
                    TelaNomeHeroi(
                        avatar: avatarSelecionado,
                        classe: classeSelecionada,
                        onComecar: { nome in
                            let avatarKey = AvatarHelper.apiKey(from: avatarSelecionado.rawValue)

                            UserDefaults.standard.set(nome, forKey: "nome_heroi")
                            UserDefaults.standard.set(
                                avatarSelecionado.rawValue,
                                forKey: "avatar_selecionado"
                            )

                            _ = try await RotinaPlusAPI.updatePerfil(
                                nomeHeroi: nome,
                                avatarKey: avatarKey,
                                classe: classeSelecionada.nome,
                                emojiClasse: classeSelecionada.emoji
                            )

                            await MainActor.run {
                                authManager.markOnboardingComplete()
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    onboarding = .home
                                }
                            }
                        },
                        onVoltar: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .escolhaAvatar
                            }
                        }
                    )
                case .home:
                    HomeView()
                }
            } else {
                NavigationStack(path: $guestPath) {
                    LoginView(
                        onCriarConta: {
                            guestPath.append(AuthGuestRoute.cadastro)
                        }
                    )
                    .navigationDestination(for: AuthGuestRoute.self) { route in
                        switch route {
                        case .cadastro:
                            CadastroView(
                                onVoltar: {
                                    guestPath.removeLast()
                                }
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            guard mostrandoLoading else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    mostrandoLoading = false
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { autenticado in
            if autenticado {
                onboarding = authManager.forceOnboarding ? .bemVindo : Self.faseInicial
                classeSelecionada = .guerreiro
                avatarSelecionado = .guaraSerio
                guestPath = NavigationPath()
            }
        }
    }
}
