// DataBindingResolver.swift
// A2UIServices
//
// JSON Pointer resolution for dynamic values
//

import Foundation
import A2UICore

/// Resolves JSON Pointer paths against data models
@MainActor
public final class DataBindingResolver: Sendable {

    public init() {}

    // MARK: - Resolving Dynamic Values

    /// Resolve a DynamicString value
    public func resolve(_ dynamicString: DynamicString, in dataModel: [String: JSONValue]) -> String {
        switch dynamicString {
        case .literal(let value):
            return value
        case .path(let path):
            let value = resolve(path: path, in: dataModel)
            return value?.stringValue ?? ""
        }
    }

    /// Resolve a DynamicNumber value
    public func resolve(_ dynamicNumber: DynamicNumber, in dataModel: [String: JSONValue]) -> Double {
        switch dynamicNumber {
        case .literal(let value):
            return value
        case .path(let path):
            let value = resolve(path: path, in: dataModel)
            return value?.numberValue ?? 0
        }
    }

    /// Resolve a DynamicBoolean value
    public func resolve(_ dynamicBoolean: DynamicBoolean, in dataModel: [String: JSONValue]) -> Bool {
        switch dynamicBoolean {
        case .literal(let value):
            return value
        case .path(let path):
            let value = resolve(path: path, in: dataModel)
            return value?.boolValue ?? false
        }
    }

    // MARK: - JSON Pointer Resolution

    /// Resolve a single value at a JSON Pointer path
    public func resolve(path: String, in dataModel: [String: JSONValue]) -> JSONValue? {
        // Handle absolute paths (start with /)
        if path.hasPrefix("/") {
            return resolveAbsolute(path: path, in: dataModel)
        }

        // Handle relative paths (no leading /)
        // For now, treat as relative to root
        // TODO: Support relative paths in list templates
        return resolveRelative(path: path, in: dataModel)
    }

    /// Resolve an absolute JSON Pointer (RFC 6901)
    private func resolveAbsolute(path: String, in dataModel: [String: JSONValue]) -> JSONValue? {
        // Remove leading slash
        let pointer = String(path.dropFirst())

        // Split into tokens
        let tokens = pointer
            .split(separator: "/")
            .map { token -> String in
                // Decode JSON Pointer escape sequences
                token
                    .replacingOccurrences(of: "~1", with: "/")
                    .replacingOccurrences(of: "~0", with: "~")
            }

        // Navigate through the data model
        var current: JSONValue? = .object(dataModel)

        for token in tokens {
            guard let value = current else { return nil }

            switch value {
            case .object(let dict):
                current = dict[token]
            case .array(let array):
                if let index = Int(token), index < array.count {
                    current = array[index]
                } else {
                    return nil
                }
            default:
                return nil
            }
        }

        return current
    }

    /// Resolve a relative path (no leading /)
    private func resolveRelative(path: String, in dataModel: [String: JSONValue]) -> JSONValue? {
        // For now, just look up directly in the root object
        return dataModel[path]
    }

    // MARK: - Resolution with Context

    /// Resolve DynamicString with optional additional context
    public func resolve(
        _ dynamicString: DynamicString,
        in dataModel: [String: JSONValue],
        with context: [String: Any]?
    ) -> String {
        switch dynamicString {
        case .literal(let value):
            return value
        case .path(let path):
            // Try to resolve from data model first
            if let value = resolve(path: path, in: dataModel) {
                return value.stringValue ?? ""
            }
            // Then try context (for relative paths in templates)
            if let contextValue = resolve(from: context, path: path) {
                if let str = contextValue as? String {
                    return str
                } else if let num = contextValue as? NSNumber {
                    return String(describing: num)
                }
            }
            return ""
        }
    }

    /// Helper to resolve values from context dictionary
    private func resolve(from context: [String: Any]?, path: String) -> Any? {
        guard let context = context else { return nil }

        // Handle paths like "text", "id", "name"
        return context[path]
    }
}
