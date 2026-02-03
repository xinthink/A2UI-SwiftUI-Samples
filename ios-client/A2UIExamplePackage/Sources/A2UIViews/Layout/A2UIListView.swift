// A2UIListView.swift
// A2UIViews
//
// List (scrollable list) component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIListView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let componentId: String
    let props: ListProperties
    let client: A2UIClient
    let contextPath: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(getChildrenWithContext(), id: \.id) { childContext in
                    A2UIRenderer(
                        surfaceId: surfaceId,
                        componentId: childContext.id,
                        client: client,
                        contextPath: childContext.contextPath
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)

                    Divider()
                }
            }
        }
    }

    private struct ChildContext: Identifiable {
        let id: String
        let contextPath: String?
    }

    private func getChildrenWithContext() -> [ChildContext] {
        // Check if this is a template-based list
        if case .template(let template) = props.children {
            let resolver = DataBindingResolver()
            let dataModel = state.getDataModel(in: surfaceId)
            let arrayValue = resolver.resolve(path: template.path, in: dataModel)

            guard case .array(let items) = arrayValue else {
                return []
            }

            return items.indices.map { index in
                let childId = "\(template.componentId)_\(index)"
                let itemContextPath = "\(template.path)/\(index)"
                return ChildContext(id: childId, contextPath: itemContextPath)
            }
        } else if case .explicitList(let ids) = props.children {
            return ids.map { ChildContext(id: $0, contextPath: contextPath) }
        }

        return []
    }
}
