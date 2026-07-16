import SwiftUI

private enum OnboardingFase {
    case bemVindo
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
                            onboarding = .escolhaAvatar
                        }
                    }
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
                                onboarding = .bemVindo
                            }
                        }
                    )
                case .nomeHeroi:
                    TelaNomeHeroi(
                        avatar: avatarSelecionado,
                        onComecar: { nome in
                            let traco = avatarSelecionado.traco
                            let avatarKey = AvatarHelper.apiKey(from: avatarSelecionado.rawValue)

                            UserDefaults.standard.set(nome, forKey: "nome_heroi")
                            UserDefaults.standard.set(
                                avatarSelecionado.rawValue,
                                forKey: "avatar_selecionado"
                            )

                            // Persiste no backend para a Home (dashboard) exibir o herói certo.
                            _ = try await RotinaPlusAPI.updatePerfil(
                                nomeHeroi: nome,
                                avatarKey: avatarKey,
                                classe: traco.nome,
                                emojiClasse: traco.emoji
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
                // MARK: Fluxo guest — Login → Criar conta
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
                // Conta nova: sempre Bem-vindo → avatar → nome → Home.
                // Login: retoma Home se o onboarding local já foi concluído.
                onboarding = authManager.forceOnboarding ? .bemVindo : Self.faseInicial
                avatarSelecionado = .guaraSerio
                guestPath = NavigationPath()
            }
        }
    }
}
