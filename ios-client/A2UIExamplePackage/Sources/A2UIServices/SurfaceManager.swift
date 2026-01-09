// SurfaceManager.swift
// A2UIServices
//
// Manages surface lifecycle, components, and data models
//

import Foundation
import A2UICore

@MainActor
public final class SurfaceManager: Sendable {

    // MARK: - Surface State

    private struct SurfaceState {
        var components: [String: ComponentWrapper] = [:]
        var dataModel: [String: JSONValue] = [:]
        var childrenMap: [String: ChildList] = [:]
    }

    private var surfaces: [String: SurfaceState] = [:]

    // MARK: - Initializer

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

    /// Get all component IDs ordered by insertion (approximate)
    public func getAllComponentIds(in surfaceId: String) -> [String] {
        return surfaces[surfaceId]?.components.keys.sorted() ?? []
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
            // Simple case: direct property update
            let key = String(path.dropFirst())
            surface.dataModel[key] = value
        }
        // For relative paths, add to root of data model
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
        // Get the array from data model using the template's dataBinding path
        let dataModel = getDataModel(in: surfaceId)
        let arrayValue = resolver.resolve(path: template.dataBinding, in: dataModel)

        guard case .array(let items) = arrayValue else {
            return []
        }

        // For now, just generate IDs using the index
        // In a real implementation, we'd maintain a mapping of template instances
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
