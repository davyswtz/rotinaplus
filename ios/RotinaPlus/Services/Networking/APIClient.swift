import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .httpError(_, let message):
            return message
        case .decodingError:
            return "Erro ao processar resposta."
        }
    }
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
    let errors: [String: [String]]?
}

class APIClient {
    static let shared = APIClient()

    private let baseURL = AppConfig.apiBaseURL
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        endpoint: Endpoints,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = Self.parseErrorMessage(from: data)
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

private struct LaravelErrorResponse: Decodable {
    let message: String?
    let errors: [String: [String]]?
}

private extension APIClient {
    static func parseErrorMessage(from data: Data) -> String {
        let decoder = JSONDecoder()

        if let laravelError = try? decoder.decode(LaravelErrorResponse.self, from: data) {
            if let fieldErrors = laravelError.errors?.values.compactMap(\.first).first {
                return fieldErrors
            }
            if let message = laravelError.message {
                return message
            }
        }

        if let apiResponse = try? decoder.decode(APIResponse<EmptyData>.self, from: data) {
            if let fieldErrors = apiResponse.errors?.values.compactMap(\.first).first {
                return fieldErrors
            }
            if let message = apiResponse.message {
                return message
            }
        }

        return "Erro na requisição."
    }
}

private struct EmptyData: Decodable {}

private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
