import Foundation

enum AppConfig {
    /// Produção (VPS) — só em builds Release.
    static let productionBaseURL = "http://181.215.135.114"

    /// Backend local via Docker (`nginx` em `localhost:8000`).
    /// No Simulador, `127.0.0.1` aponta para o Mac.
    static let developmentBaseURL = "http://127.0.0.1:8000"

    static var apiBaseURL: String {
        #if DEBUG
        return developmentBaseURL
        #else
        return productionBaseURL
        #endif
    }
}
