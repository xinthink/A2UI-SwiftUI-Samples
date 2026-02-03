// Types.swift
// A2UICore
//
// Foundation types for A2UI protocol v0.9
//

import Foundation

// MARK: - DynamicString

/// A value that can be either a literal string or a path reference
public enum DynamicString: Codable, Equatable, Sendable {
    case literal(String)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // v0.9: Try direct string first (most common case)
        if let stringValue = try? container.decode(String.self) {
            self = .literal(stringValue)
            return
        }

        // v0.8/v0.9: Try path wrapper format
        if let dict = try? container.decode([String: String].self) {
            if let path = dict["path"] {
                self = .path(path)
                return
            }
            // v0.8 legacy: literalString wrapper
            if let literal = dict["literalString"] {
                self = .literal(literal)
                return
            }
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "DynamicString must be a string or an object with 'path' key"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literal(let value):
            // v0.9: Encode as direct string
            try container.encode(value)
        case .path(let value):
            // v0.9: Encode as path wrapper
            try container.encode(["path": value])
        }
    }
}

// MARK: - DynamicNumber

/// A value that can be either a literal number or a path reference
public enum DynamicNumber: Codable, Equatable, Sendable {
    case literal(Double)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // v0.9: Try direct number first
        if let numberValue = try? container.decode(Double.self) {
            self = .literal(numberValue)
            return
        }

        // v0.8/v0.9: Try path wrapper
        if let dict = try? container.decode([String: String].self),
           let path = dict["path"] {
            self = .path(path)
            return
        }

        // v0.8 legacy: literalNumber wrapper
        if let dict = try? container.decode([String: Double].self),
           let literal = dict["literalNumber"] {
            self = .literal(literal)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "DynamicNumber must be a number or an object with 'path' key"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literal(let value):
            try container.encode(value)
        case .path(let value):
            try container.encode(["path": value])
        }
    }
}

// MARK: - DynamicBoolean

/// A value that can be either a literal boolean or a path reference
public enum DynamicBoolean: Codable, Equatable, Sendable {
    case literal(Bool)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // v0.9: Try direct boolean first
        if let boolValue = try? container.decode(Bool.self) {
            self = .literal(boolValue)
            return
        }

        // v0.8/v0.9: Try path wrapper
        if let dict = try? container.decode([String: String].self),
           let path = dict["path"] {
            self = .path(path)
            return
        }

        // v0.8 legacy: literalBoolean wrapper
        if let dict = try? container.decode([String: Bool].self),
           let literal = dict["literalBoolean"] {
            self = .literal(literal)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "DynamicBoolean must be a boolean or an object with 'path' key"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literal(let value):
            try container.encode(value)
        case .path(let value):
            try container.encode(["path": value])
        }
    }
}

// MARK: - ChildList

/// Helper for decoding wrapped explicit list format (v0.8 legacy)
private struct ExplicitListWrapper: Decodable {
    let explicitList: [String]
}

/// Defines how containers hold children - either explicit list or template
public enum ChildList: Codable, Equatable, Sendable {
    case explicitList([String])
    case template(TemplateDefinition)

    public init(from decoder: Decoder) throws {
        // Try keyed container first (when children is a key in a component)
        if let keyedContainer = try? decoder.container(keyedBy: ChildListCodingKeys.self) {
            if let explicitList = try? keyedContainer.decode([String].self, forKey: .explicitList) {
                self = .explicitList(explicitList)
                return
            }
            if let template = try? keyedContainer.decode(TemplateDefinition.self, forKey: .template) {
                self = .template(template)
                return
            }
            if let explicitList = try? keyedContainer.decode([String].self, forKey: .children) {
                // Handle explicitList wrapped format from keyed container
                self = .explicitList(explicitList)
                return
            }
        }

        // Try single value container (direct array or object)
        let container = try decoder.singleValueContainer()

        // v0.9: Try direct array first (most common case)
        if let explicitList = try? container.decode([String].self) {
            self = .explicitList(explicitList)
            return
        }

        // v0.9: Try template format
        if let template = try? container.decode(TemplateDefinition.self) {
            self = .template(template)
            return
        }

        // v0.8 legacy: Try wrapped explicitList format
        if let wrapper = try? container.decode(ExplicitListWrapper.self) {
            self = .explicitList(wrapper.explicitList)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "ChildList must be an array or TemplateDefinition"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .explicitList(let items):
            // v0.9: Encode as direct array
            try container.encode(items)
        case .template(let template):
            try container.encode(template)
        }
    }

    // MARK: - Private

    private enum ChildListCodingKeys: String, CodingKey {
        case explicitList, template, children
    }
}

// MARK: - TemplateDefinition

/// Template for dynamic list generation
public struct TemplateDefinition: Codable, Equatable, Sendable {
    public let path: String  // v0.9: Renamed from dataBinding
    public let componentId: String

    private enum CodingKeys: String, CodingKey {
        case path, componentId
        case dataBinding  // v0.8 legacy key
    }

    public init(path: String, componentId: String) {
        self.path = path
        self.componentId = componentId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.componentId = try container.decode(String.self, forKey: .componentId)

        // v0.9: Try path key first
        if let path = try? container.decode(String.self, forKey: .path) {
            self.path = path
        } else if let dataBinding = try? container.decode(String.self, forKey: .dataBinding) {
            // v0.8 legacy: Fall back to dataBinding
            self.path = dataBinding
        } else {
            throw DecodingError.keyNotFound(CodingKeys.path, .init(
                codingPath: container.codingPath,
                debugDescription: "TemplateDefinition must have either 'path' or 'dataBinding' key"
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(componentId, forKey: .componentId)
        // v0.9: Always encode with 'path' key
        try container.encode(path, forKey: .path)
    }
}
