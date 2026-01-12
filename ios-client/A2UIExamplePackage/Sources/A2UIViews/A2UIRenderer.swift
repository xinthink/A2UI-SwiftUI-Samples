// A2UIRenderer.swift
// A2UIViews
//
// Main A2UI SwiftUI renderer
//

import SwiftUI
import A2UICore
import A2UIServices

/// Main view that renders A2UI components
public struct A2UIRenderer: View {
    @Environment(A2UIState.self) private var state

    private let surfaceId: String
    private let componentId: String
    private let client: A2UIClient
    private let contextPath: String?

    public init(surfaceId: String, componentId: String?, client: A2UIClient, contextPath: String? = nil) {
        self.surfaceId = surfaceId
        self.componentId = componentId ?? "root"
        self.client = client
        self.contextPath = contextPath
    }

    public var body: some View {
        // Access revision to trigger observation
        let _ = state.revision

        if let componentWrapper = getComponent(id: componentId) {
            A2UIComponentView(
                surfaceId: surfaceId,
                componentId: componentId,
                componentWrapper: componentWrapper,
                client: client,
                contextPath: contextPath
            )
        } else {
            EmptyView()
        }
    }

    private func getComponent(id: String) -> ComponentWrapper? {
        // Direct lookup first
        if let component = state.getComponent(id: id, in: surfaceId) {
            return component
        }

        // For template instances (e.g., "todo_item_0"), look up base template
        if let underscoreIndex = id.lastIndex(of: "_"),
           let _ = Int(id[id.index(after: underscoreIndex)...]) {
            let baseId = String(id[..<underscoreIndex])
            return state.getComponent(id: baseId, in: surfaceId)
        }

        return nil
    }
}

// MARK: - A2UIComponentView

/// Generic component renderer that switches on component type
internal struct A2UIComponentView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let componentId: String
    let componentWrapper: ComponentWrapper
    let client: A2UIClient
    let contextPath: String?

    var body: some View {
        let component = componentWrapper.component

        switch component {
        case .row(let props):
            A2UIRowView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .column(let props):
            A2UIColumnView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .text(let props):
            A2UITextView(surfaceId: surfaceId, props: props, contextPath: contextPath)
        case .image(let props):
            A2UIImageView(surfaceId: surfaceId, props: props, contextPath: contextPath)
        case .icon(let props):
            A2UIIconView(surfaceId: surfaceId, props: props, contextPath: contextPath)
        case .divider(let props):
            A2UIDividerView(props: props)
        case .button(let props):
            A2UIButtonView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .textField(let props):
            A2UITextFieldView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                contextPath: contextPath
            )
        case .checkbox(let props):
            A2UICheckboxView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                contextPath: contextPath
            )
        case .card(let props):
            A2UICardView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .modal(let props):
            A2UIModalView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .tabs(let props):
            A2UITabsView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        case .list(let props):
            A2UIListView(
                surfaceId: surfaceId,
                componentId: componentId,
                props: props,
                client: client,
                contextPath: contextPath
            )
        }
    }
}

// MARK: - Helper Views

/// Wrapper view that applies weight and renders children
internal struct A2UIChildView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let childId: String
    let weight: Double?
    let client: A2UIClient
    let contextPath: String?

    var body: some View {
        let view = A2UIRenderer(
            surfaceId: surfaceId,
            componentId: childId,
            client: client,
            contextPath: contextPath
        )

        if weight == nil {
            view
        } else {
            view
                .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}
