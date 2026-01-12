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

/// Per-surface state
public struct SurfaceState: Sendable {
    var components: [String: ComponentWrapper] = [:]
    var dataModel: [String: JSONValue] = [:]
    var childrenMap: [String: ChildList] = [:]
}

/// App state for managing multiple surfaces
@MainActor
@Observable
public final class A2UIState {
    public private(set) var surfaces: [String: SurfaceState] = [:] {
        didSet { revision += 1 }
    }
    public var currentSurfaceId: String? {
        didSet { revision += 1 }
    }
    public var isConnected: Bool = false
    public var errorMessage: String?

    /// Revision counter to force SwiftUI observation
    public var revision: Int = 0

    public init() {}

    // MARK: - Component Management

    /// Update or add components to a surface
    public func updateComponents(_ components: [ComponentWrapper], in surfaceId: String) {
        var surface = getOrCreateSurface(surfaceId)

        for component in components {
            surface.components[component.id] = component

            // Store children for layout components
            switch component.component {
            case .row(let props):
                surface.childrenMap[component.id] = props.children
            case .column(let props):
                surface.childrenMap[component.id] = props.children
            case .list(let props):
                surface.childrenMap[component.id] = props.children
            default:
                break
            }
        }

        surfaces[surfaceId] = surface
    }

    /// Get a component by ID
    public func getComponent(id: String, in surfaceId: String) -> ComponentWrapper? {
        return surfaces[surfaceId]?.components[id]
    }

    // MARK: - Data Model Management

    /// Update data model at a JSON Pointer path
    public func updateDataModel(path: String, value: JSONValue, in surfaceId: String) {
        var surface = getOrCreateSurface(surfaceId)

        // For root path ("/"), replace the entire data model
        if path == "/" {
            if case .object(let dict) = value {
                surface.dataModel = dict
            } else if case .null = value {
                surface.dataModel = [:]
            }
        }
        // For specific paths, update the data model
        else if path.hasPrefix("/") {
            let key = String(path.dropFirst())
            surface.dataModel[key] = value
        }
        else {
            surface.dataModel[path] = value
        }

        surfaces[surfaceId] = surface
    }

    /// Get current data model
    public func getDataModel(in surfaceId: String) -> [String: JSONValue] {
        return surfaces[surfaceId]?.dataModel ?? [:]
    }

    /// Get data model value at a specific path
    public func getDataModel(path: String, in surfaceId: String) -> JSONValue? {
        let dataModel = getDataModel(in: surfaceId)

        if path == "/" {
            return .object(dataModel)
        } else if path.hasPrefix("/") {
            let key = String(path.dropFirst())
            return dataModel[key]
        } else {
            return dataModel[path]
        }
    }

    // MARK: - Children Management

    /// Get the child list for a component
    public func getChildren(of componentId: String, in surfaceId: String) -> ChildList? {
        return surfaces[surfaceId]?.childrenMap[componentId]
    }

    /// Resolve children to actual component IDs
    public func resolveChildren(
        _ childList: ChildList,
        in surfaceId: String,
        with resolver: DataBindingResolver
    ) -> [String] {
        switch childList {
        case .explicitList(let ids):
            return ids
        case .template(let template):
            return resolveTemplate(template, in: surfaceId, with: resolver)
        }
    }

    /// Resolve template to component IDs (for dynamic lists)
    private func resolveTemplate(
        _ template: TemplateDefinition,
        in surfaceId: String,
        with resolver: DataBindingResolver
    ) -> [String] {
        let dataModel = getDataModel(in: surfaceId)
        let arrayValue = resolver.resolve(path: template.dataBinding, in: dataModel)

        guard case .array(let items) = arrayValue else {
            return []
        }

        return items.indices.map { index in
            "\(template.componentId)_\(index)"
        }
    }

    // MARK: - Surface Lifecycle

    /// Create a new surface
    public func createSurface(id: String) {
        surfaces[id] = SurfaceState()
    }

    /// Delete a surface and its data
    public func deleteSurface(id: String) {
        surfaces.removeValue(forKey: id)
        if currentSurfaceId == id {
            currentSurfaceId = nil
        }
    }

    /// Check if surface exists
    public func hasSurface(id: String) -> Bool {
        return surfaces[id] != nil
    }

    // MARK: - Helper Methods

    private func getOrCreateSurface(_ surfaceId: String) -> SurfaceState {
        if let surface = surfaces[surfaceId] {
            return surface
        }
        return SurfaceState()
    }
}
