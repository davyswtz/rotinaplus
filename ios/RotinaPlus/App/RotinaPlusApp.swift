import SwiftUI

@main
struct RotinaPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // MARK: Tela inicial do app — login antes de qualquer outra tela
            LoginView()
        }
    }
}
