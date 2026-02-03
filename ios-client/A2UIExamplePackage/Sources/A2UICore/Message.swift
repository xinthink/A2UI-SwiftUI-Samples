// Message.swift
// A2UICore
//
// Protocol message definitions for A2UI v0.9 (Pure v0.9 - no v0.8 compatibility)
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

        // v0.9: Decode version field (required for message format)
        _ = try container.decode(String.self, forKey: .version)

        // Try each message type and track which one succeeds
        var lastError: Error?

        do {
            let createSurface = try container.decode(CreateSurfaceMessage.self, forKey: .createSurface)
            self = .createSurface(createSurface)
            return
        } catch {
            lastError = error
        }

        do {
            let updateComponents = try container.decode(UpdateComponentsMessage.self, forKey: .updateComponents)
            self = .updateComponents(updateComponents)
            return
        } catch {
            // Include this in the final error for debugging
            print("ServerMessage: updateComponents decode failed: \(error)")
        }

        do {
            let updateDataModel = try container.decode(UpdateDataModelMessage.self, forKey: .updateDataModel)
            self = .updateDataModel(updateDataModel)
            return
        } catch {
            print("ServerMessage: updateDataModel decode failed: \(error)")
        }

        do {
            let deleteSurface = try container.decode(DeleteSurfaceMessage.self, forKey: .deleteSurface)
            self = .deleteSurface(deleteSurface)
            return
        } catch {
            print("ServerMessage: deleteSurface decode failed: \(error)")
        }

        // All attempts failed - provide detailed error
        throw DecodingError.dataCorruptedError(
            forKey: CodingKeys.createSurface,
            in: container,
            debugDescription: "ServerMessage decode failed. Last error: \(String(describing: lastError)). Content keys: \(container.allKeys.map { $0.stringValue })"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("v0.9", forKey: .version)

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
        case version
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
/// Supports flat format where id, weight, component type, and properties are all siblings
public struct ComponentWrapper: Codable, Sendable, Equatable {
    public let id: String
    public let weight: Double?
    public let component: Component

    public init(id: String, weight: Double? = nil, component: Component) {
        self.id = id
        self.weight = weight
        self.component = component
    }

    public init(from decoder: Decoder) throws {
        // Flat format: all keys are siblings at the same level
        let container = try decoder.container(keyedBy: FlatCodingKeys.self)

        // Decode id and weight (may not be present in some formats)
        let id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        let weight = try container.decodeIfPresent(Double.self, forKey: .weight)

        // Decode component type
        let componentType = try container.decode(String.self, forKey: .component)

        // Decode component based on type using shared decoder context
        let component = try Self.decodeComponent(from: decoder, type: componentType)

        self.id = id
        self.weight = weight
        self.component = component
    }

    private static func decodeComponent(from decoder: Decoder, type componentType: String) throws -> Component {
        switch componentType {
        case "Row":
            return .row(try RowProperties(from: decoder))
        case "Column":
            return .column(try ColumnProperties(from: decoder))
        case "Text":
            return .text(try TextProperties(from: decoder))
        case "Image":
            return .image(try ImageProperties(from: decoder))
        case "Icon":
            return .icon(try IconProperties(from: decoder))
        case "Divider":
            return .divider(try DividerProperties(from: decoder))
        case "Button":
            return .button(try ButtonProperties(from: decoder))
        case "TextField":
            return .textField(try TextFieldProperties(from: decoder))
        case "CheckBox":
            return .checkbox(try CheckboxProperties(from: decoder))
        case "Card":
            return .card(try CardProperties(from: decoder))
        case "Modal":
            return .modal(try ModalProperties(from: decoder))
        case "Tabs":
            return .tabs(try TabsProperties(from: decoder))
        case "List":
            return .list(try ListProperties(from: decoder))
        default:
            let container = try decoder.container(keyedBy: FlatCodingKeys.self)
            throw DecodingError.dataCorruptedError(
                forKey: .component,
                in: container,
                debugDescription: "Unknown component type: \(componentType)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FlatCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encode(component, forKey: .component)
    }

    // MARK: - Private Coding Key Type

    /// Coding keys that cover all possible properties in flat component format
    private enum FlatCodingKeys: String, CodingKey {
        case id, weight, component
        case children, justify, align, text, label, value, variant, action, enabled
        case name, axis, fit, accessibility, direction, content, trigger, tabs, child
    }
}
