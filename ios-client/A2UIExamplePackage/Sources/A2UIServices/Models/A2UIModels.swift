// A2UIModels.swift
// A2UIServices
//
// Domain models for A2UI client
//

import Foundation
import A2UICore

/// Action sent from client to server
public struct ClientAction: Codable, Sendable, Equatable {
    public let action: String
    public let surfaceId: String
    public let context: [String: JSONValue]?

    public init(action: String, surfaceId: String, context: [String: JSONValue]? = nil) {
        self.action = action
        self.surfaceId = surfaceId
        self.context = context
    }
}

/// App state for managing multiple surfaces
@MainActor
@Observable
public final class A2UIState {
    public var surfaceManager: SurfaceManager
    public var currentSurfaceId: String?
    public var isConnected: Bool = false
    public var errorMessage: String?

    public init(surfaceManager: SurfaceManager = SurfaceManager()) {
        self.surfaceManager = surfaceManager
    }
}
