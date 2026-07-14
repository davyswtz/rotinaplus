import SwiftUI

private enum OnboardingFase {
    case bemVindo
    case criePersonagem
    case home
}

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var onboarding: OnboardingFase = .bemVindo

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                switch onboarding {
                case .bemVindo:
                    TelaBemVindo {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            onboarding = .criePersonagem
                        }
                    }
                case .criePersonagem:
                    TelaCriePersonagem {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            onboarding = .home
                        }
                    }
                case .home:
                    HomeView()
                }
            } else {
                LoginView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { autenticado in
            if autenticado {
                onboarding = .bemVindo
            }
        }
    }
}
