// A2UIColumnView.swift
// A2UIViews
//
// Column (vertical layout) component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIColumnView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let componentId: String
    let props: ColumnProperties
    let client: A2UIClient

    @State private var resolver = DataBindingResolver()

    var body: some View {
        let childIds = state.resolveChildren(
            props.children,
            in: surfaceId,
            with: resolver
        )

        let alignment = resolveAlignment(props.alignment)

        VStack(alignment: alignment, spacing: determineSpacing()) {
            ForEach(childIds, id: \.self) { childId in
                let weight = getWeight(for: childId)
                A2UIChildView(
                    surfaceId: surfaceId,
                    childId: childId,
                    weight: weight,
                    client: client
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func getWeight(for componentId: String) -> Double? {
        return state.getComponent(id: componentId, in: surfaceId)?.weight
    }

    private func resolveAlignment(_ alignment: String?) -> HorizontalAlignment {
        switch alignment {
        case "start", "left":
            return .leading
        case "end", "right":
            return .trailing
        case "center":
            return .center
        case "stretch":
            return .leading // SwiftUI handles stretch automatically
        default:
            return .leading
        }
    }

    private func determineSpacing() -> CGFloat {
        // TODO: Make this configurable
        return 8
    }
}
