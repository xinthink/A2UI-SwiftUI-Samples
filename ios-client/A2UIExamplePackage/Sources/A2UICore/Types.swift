// Types.swift
// A2UICore
//
// Foundation types for A2UI protocol v0.9
//

import Foundation

// MARK: - DynamicString

/// A value that can be either a literal string, a path reference, or a function call
public enum DynamicString: Codable, Equatable, Sendable {
    case literalString(String)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: String].self) {
            if let literal = dict["literalString"] {
                self = .literalString(literal)
            } else if let path = dict["path"] {
                self = .path(path)
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "DynamicString must contain either 'literalString' or 'path' key"
                )
            }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "DynamicString must be an object"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literalString(let value):
            try container.encode(["literalString": value])
        case .path(let value):
            try container.encode(["path": value])
        }
    }
}

// MARK: - DynamicNumber

/// A value that can be either a literal number or a path reference
public enum DynamicNumber: Codable, Equatable, Sendable {
    case literalNumber(Double)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: String].self) {
            if let path = dict["path"] {
                self = .path(path)
                return
            }
        }
        if let dict = try? container.decode([String: Double].self) {
            if let literal = dict["literalNumber"] {
                self = .literalNumber(literal)
                return
            }
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "DynamicNumber must contain either 'literalNumber' or 'path' key"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literalNumber(let value):
            try container.encode(["literalNumber": value])
        case .path(let value):
            try container.encode(["path": value])
        }
    }
}

// MARK: - DynamicBoolean

/// A value that can be either a literal boolean or a path reference
public enum DynamicBoolean: Codable, Equatable, Sendable {
    case literalBoolean(Bool)
    case path(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: String].self) {
            if let path = dict["path"] {
                self = .path(path)
                return
            }
        }
        if let dict = try? container.decode([String: Bool].self) {
            if let literal = dict["literalBoolean"] {
                self = .literalBoolean(literal)
                return
            }
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "DynamicBoolean must contain either 'literalBoolean' or 'path' key"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .literalBoolean(let value):
            try container.encode(["literalBoolean": value])
        case .path(let value):
            try container.encode(["path": value])
        }
    }
}

// MARK: - ChildList

/// Helper for decoding wrapped explicit list format: {"explicitList": ["id1", "id2"]}
private struct ExplicitListWrapper: Decodable {
    let explicitList: [String]
}

/// Helper for decoding wrapped template format: {"template": {...}}
private struct TemplateWrapper: Decodable {
    let template: TemplateDefinition
}

/// Defines how containers hold children - either explicit list or template
public enum ChildList: Codable, Equatable, Sendable {
    case explicitList([String])
    case template(TemplateDefinition)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Try decoding as direct template (object with dataBinding/componentId at top level)
        if let template = try? container.decode(TemplateDefinition.self) {
            self = .template(template)
        }
        // Try decoding as wrapped template {"template": {...}}
        else if let wrapper = try? container.decode(TemplateWrapper.self) {
            self = .template(wrapper.template)
        }
        // Try decoding as explicit list (direct array) - Protocol 0.9.md format
        else if let explicitList = try? container.decode([String].self) {
            self = .explicitList(explicitList)
        }
        // Try decoding as wrapped object {"explicitList": [...]} - Components Reference format
        else if let wrapper = try? container.decode(ExplicitListWrapper.self) {
            self = .explicitList(wrapper.explicitList)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "ChildList must be an array, TemplateDefinition, {template: {...}}, or {explicitList: [...]}"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .explicitList(let items):
            try container.encode(items)
        case .template(let template):
            try container.encode(template)
        }
    }
}

// MARK: - TemplateDefinition

/// Template for dynamic list generation
public struct TemplateDefinition: Codable, Equatable, Sendable {
    public let dataBinding: String  // JSON Pointer path to array
    public let componentId: String  // Component ID to use for each item

    public init(dataBinding: String, componentId: String) {
        self.dataBinding = dataBinding
        self.componentId = componentId
    }
}
