// A2UITextView.swift
// A2UIViews
//
// Text component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UITextView: View {
    @Environment(A2UIState.self) private var state
    @State private var resolver = DataBindingResolver()

    let surfaceId: String
    let props: TextProperties

    var body: some View {
        let dataModel = state.getDataModel(in: surfaceId)
        let text = resolver.resolve(props.text, in: dataModel)
        let alignment = resolveAlignment(props.alignment)

        Text(text)
            .multilineTextAlignment(alignment)
            .accessibilityLabel("Text: \(text)")
    }

    private func resolveAlignment(_ alignment: String?) -> TextAlignment {
        switch alignment {
        case "start", "left":
            return .leading
        case "end", "right":
            return .trailing
        case "center":
            return .center
        default:
            return .leading
        }
    }
}
