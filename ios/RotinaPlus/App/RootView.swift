import SwiftUI

private enum OnboardingFase {
    case bemVindo
    case escolhaAvatar
    case nomeHeroi
    case home
}

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var onboarding: OnboardingFase = Self.faseInicial
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
                            UserDefaults.standard.set(nome, forKey: "nome_heroi")
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .home
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
                LoginView()
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
                onboarding = Self.faseInicial
                avatarSelecionado = .guaraSerio
            }
        }
    }
}
