import SwiftUI

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @AppStorage("rotinaplus.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("rotinaplus.hasCharacter") private var hasCharacter = false

    /// Temporário: force a tela de criação para preview no simulador.
    private let forcarCriacaoPersonagem = true

    var body: some View {
        Group {
            if forcarCriacaoPersonagem {
                CriacaoPersonagemView {
                    hasCharacter = true
                }
            } else if authManager.isAuthenticated {
                if !hasCompletedOnboarding {
                    TelaBemVindo {
                        hasCompletedOnboarding = true
                    }
                } else if !hasCharacter {
                    CriacaoPersonagemView {
                        hasCharacter = true
                    }
                } else {
                    HomeView()
                }
            } else {
                LoginView()
            }
        }
    }
}
