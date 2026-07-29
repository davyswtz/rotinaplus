import SwiftUI

@main
struct RotinaPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    OfflineSyncEngine.shared.start()
                    LembretesService.shared.configurar()
                    Task {
                        _ = await LembretesService.shared.pedirPermissaoSeNecessario()
                        await LembretesService.shared.reagendarTudo()
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        Task {
                            await OfflineSyncEngine.shared.flush()
                            await LembretesService.shared.reagendarTudo()
                        }
                    }
                }
        }
    }
}
