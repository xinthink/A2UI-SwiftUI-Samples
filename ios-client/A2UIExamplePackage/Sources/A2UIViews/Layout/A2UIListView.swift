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

    @State private var resolver = DataBindingResolver()

    var body: some View {
        let childIds = state.surfaceManager.resolveChildren(
            props.children,
            in: surfaceId,
            with: resolver
        )

        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(childIds, id: \.self) { childId in
                    A2UIRenderer(surfaceId: surfaceId, componentId: childId, client: client)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)

                    Divider()
                }
            }
        }
    }
}
