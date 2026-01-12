// A2UIRowView.swift
// A2UIViews
//
// Row (horizontal layout) component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIRowView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let componentId: String
    let props: RowProperties
    let client: A2UIClient
    let contextPath: String?

    var body: some View {
        let resolver = DataBindingResolver()
        let childIds = state.resolveChildren(
            props.children,
            in: surfaceId,
            with: resolver
        )

        let alignment = resolveAlignment(props.alignment)

        HStack(alignment: alignment, spacing: determineSpacing()) {
            ForEach(childIds, id: \.self) { childId in
                let weight = getWeight(for: childId)
                A2UIChildView(
                    surfaceId: surfaceId,
                    childId: childId,
                    weight: weight,
                    client: client,
                    contextPath: contextPath
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func getWeight(for componentId: String) -> Double? {
        return state.getComponent(id: componentId, in: surfaceId)?.weight
    }

    private func resolveAlignment(_ alignment: String?) -> VerticalAlignment {
        switch alignment {
        case "top", "start":
            return .top
        case "bottom", "end":
            return .bottom
        case "center":
            return .center
        case "stretch":
            return .center // SwiftUI handles stretch automatically
        default:
            return .center
        }
    }

    private func determineSpacing() -> CGFloat {
        // TODO: Make this configurable
        return 8
    }
}
