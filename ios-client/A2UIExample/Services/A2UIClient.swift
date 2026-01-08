import Foundation

class A2UIClient {
    static let shared = A2UIClient()
    private let baseURL = "http://localhost:3000"

    private init() {}

    func fetchPayload(endpoint: String) async throws -> [A2UIMessage] {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw A2UIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw A2UIError.serverError
        }

        do {
            let messages = try JSONDecoder().decode([A2UIMessage].self, from: data)
            return messages
        } catch {
            print("Failed to decode A2UI messages: \(error)")
            throw A2UIError.decodingError(error.localizedDescription)
        }
    }

    func sendUserAction(_ action: UserAction) async throws {
        guard let url = URL(string: "\(baseURL)/api/action") else {
            throw A2UIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(action)
        } catch {
            throw A2UIError.encodingError(error.localizedDescription)
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw A2UIError.serverError
        }

        print("User action sent successfully")
    }
}

enum A2UIError: Error {
    case invalidURL
    case serverError
    case decodingError(String)
    case encodingError(String)
    case networkError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .serverError:
            return "Server error occurred"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .encodingError(let message):
            return "Failed to encode request: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}