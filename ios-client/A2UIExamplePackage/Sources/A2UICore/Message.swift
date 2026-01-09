// Message.swift
// A2UICore
//
// Protocol message definitions for A2UI v0.9
//

import Foundation

// MARK: - ServerMessage

/// Top-level message envelope for all server-to-client communication
public enum ServerMessage: Codable, Sendable {
    case createSurface(CreateSurfaceMessage)
    case updateComponents(UpdateComponentsMessage)
    case updateDataModel(UpdateDataModelMessage)
    case deleteSurface(DeleteSurfaceMessage)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let createSurface = try? container.decode(CreateSurfaceMessage.self, forKey: .createSurface) {
            self = .createSurface(createSurface)
        } else if let updateComponents = try? container.decode(UpdateComponentsMessage.self, forKey: .updateComponents) {
            self = .updateComponents(updateComponents)
        } else if let updateDataModel = try? container.decode(UpdateDataModelMessage.self, forKey: .updateDataModel) {
            self = .updateDataModel(updateDataModel)
        } else if let deleteSurface = try? container.decode(DeleteSurfaceMessage.self, forKey: .deleteSurface) {
            self = .deleteSurface(deleteSurface)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.createSurface,
                in: container,
                debugDescription: "ServerMessage must contain one of: createSurface, updateComponents, updateDataModel, deleteSurface"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .createSurface(let value):
            try container.encode(value, forKey: .createSurface)
        case .updateComponents(let value):
            try container.encode(value, forKey: .updateComponents)
        case .updateDataModel(let value):
            try container.encode(value, forKey: .updateDataModel)
        case .deleteSurface(let value):
            try container.encode(value, forKey: .deleteSurface)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case createSurface
        case updateComponents
        case updateDataModel
        case deleteSurface
    }

    // MARK: - CreateSurfaceMessage

    /// Initialize a new UI surface
    public struct CreateSurfaceMessage: Codable, Sendable, Equatable {
        public let surfaceId: String
        public let catalogId: String?

        public init(surfaceId: String, catalogId: String? = nil) {
            self.surfaceId = surfaceId
            self.catalogId = catalogId
        }
    }

    // MARK: - UpdateComponentsMessage

    /// Update component definitions for a surface
    public struct UpdateComponentsMessage: Codable, Sendable, Equatable {
        public let surfaceId: String
        public let components: [ComponentWrapper]

        public init(surfaceId: String, components: [ComponentWrapper]) {
            self.surfaceId = surfaceId
            self.components = components
        }
    }

    // MARK: - UpdateDataModelMessage

    /// Update data model for a surface
    public struct UpdateDataModelMessage: Codable, Sendable, Equatable {
        public let surfaceId: String
        public let path: String        // JSON Pointer
        public let value: JSONValue

        public init(surfaceId: String, path: String, value: JSONValue) {
            self.surfaceId = surfaceId
            self.path = path
            self.value = value
        }
    }

    // MARK: - DeleteSurfaceMessage

    /// Remove a surface and its contents
    public struct DeleteSurfaceMessage: Codable, Sendable, Equatable {
        public let surfaceId: String

        public init(surfaceId: String) {
            self.surfaceId = surfaceId
        }
    }
}

// MARK: - JSONValue

/// A type-erased JSON value for dynamic data model storage
public enum JSONValue: Codable, Sendable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .number(Double(int))
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid JSON value"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }

    // MARK: - Convenience accessors

    public var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }

    public var numberValue: Double? {
        if case .number(let value) = self { return value }
        return nil
    }

    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    public var arrayValue: [JSONValue]? {
        if case .array(let value) = self { return value }
        return nil
    }

    public var objectValue: [String: JSONValue]? {
        if case .object(let value) = self { return value }
        return nil
    }
}

// MARK: - ComponentWrapper

/// Wrapper for components with ID and weight (for Row/Column children)
public struct ComponentWrapper: Codable, Sendable, Equatable {
    public let id: String
    public let weight: Double?
    public let component: Component

    public init(id: String, weight: Double? = nil, component: Component) {
        self.id = id
        self.weight = weight
        self.component = component
    }
}
