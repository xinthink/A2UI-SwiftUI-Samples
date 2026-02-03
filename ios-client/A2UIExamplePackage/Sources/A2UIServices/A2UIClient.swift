// A2UIClient.swift
// A2UIServices
//
// HTTP client for A2UI protocol communication
//

import Foundation
import A2UICore

/// HTTP client for communicating with A2UI server
@MainActor
public final class A2UIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    public weak var delegate: A2UIClientDelegate?

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Server Connection

    /// Fetch initial UI payload from server endpoint
    public func fetchSurface(from endpoint: String) async throws {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw A2UIError.serverError("Invalid response")
        }

        // Handle JSON Lines (NDJSON) format
        let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
        print("Get JSON lines: \(lines)")

        for line in lines where !line.isEmpty {
            guard let lineData = line.data(using: .utf8) else {
                print("A2UIClient: Skipping line - invalid UTF8")
                continue
            }

            do {
                let message = try JSONDecoder().decode(ServerMessage.self, from: lineData)
                await delegate?.didReceive(message: message)
            } catch {
                print("A2UIClient: Failed to decode message - \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("  Context: \(context.debugDescription)")
                        print("  CodingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .keyNotFound(let key, let context):
                        print("  Key not found: \(key.stringValue)")
                        print("  Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("  Type mismatch: expected \(type)")
                        print("  Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("  Value not found: expected \(type)")
                        print("  Context: \(context.debugDescription)")
                    @unknown default:
                        print("  Unknown error")
                    }
                }
                let preview = String(data: lineData, encoding: .utf8) ?? "(binary data)"
                print("  Line content (first 500 chars): \(String(preview.prefix(500)))")
            }
        }
    }

    /// Send user action to server
    public func sendAction(_ action: ClientAction) async throws {
        let url = baseURL.appendingPathComponent("/api/action")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(action)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw A2UIError.serverError("Action failed")
        }
    }

    /// Check server health
    public func checkHealth() async throws -> Bool {
        let url = baseURL.appendingPathComponent("/health")
        let (_, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }
}

// MARK: - Delegate Protocol

@MainActor
public protocol A2UIClientDelegate: AnyObject {
    func didReceive(message: ServerMessage) async
}

// MARK: - Errors

public enum A2UIError: LocalizedError {
    case serverError(String)
    case decodingError(String)
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
