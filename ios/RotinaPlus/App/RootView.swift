import SwiftUI

private enum OnboardingFase {
    case bemVindo
    case escolhaAvatar
    case home
}

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var onboarding: OnboardingFase = .bemVindo
    @State private var avatarSelecionado: AvatarExplorador?
    @State private var mostrandoLoading = true

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
                                onboarding = .home
                            }
                        },
                        onVoltar: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboarding = .bemVindo
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
                onboarding = .bemVindo
                avatarSelecionado = nil
            }
        }
    }
}
