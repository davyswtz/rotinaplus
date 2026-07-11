import Foundation

enum AppConfig {
    static let productionBaseURL = "http://181.215.135.114"
    static let developmentBaseURL = "http://127.0.0.1:8000"

    static var apiBaseURL: String {
        #if DEBUG
        return developmentBaseURL
        #else
        return productionBaseURL
        #endif
    }
}
