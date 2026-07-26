import Foundation

enum AppConfig {
    /// Produção (VPS) — banco e usuários reais do Rotina Plus.
    static let productionBaseURL = "http://181.215.135.114"

    /// Backend local via Docker (`nginx` em `localhost:8000`).
    /// No Simulador, `127.0.0.1` aponta para o Mac.
    static let developmentBaseURL = "http://127.0.0.1:8000"

    /// `true` = usa a API/banco da VPS mesmo em Debug (login com contas cadastradas).
    /// `false` = usa o backend local Docker.
    static let useRemoteAPI = true

    static var apiBaseURL: String {
        #if DEBUG
        return useRemoteAPI ? productionBaseURL : developmentBaseURL
        #else
        return productionBaseURL
        #endif
    }
}
