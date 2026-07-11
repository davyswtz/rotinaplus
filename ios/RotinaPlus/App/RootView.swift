import SwiftUI

struct RootView: View {
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TelaBemVindo()
            } else {
                LoginView()
            }
        }
    }
}
