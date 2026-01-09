// A2UITextFieldView.swift
// A2UIViews
//
// Text input field component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UITextFieldView: View {
    @Environment(A2UIState.self) private var state
    @FocusState private var isFocused: Bool

    let surfaceId: String
    let componentId: String
    let props: TextFieldProperties

    @State private var text: String
    @State private var resolver = DataBindingResolver()

    init(surfaceId: String, componentId: String, props: TextFieldProperties) {
        self.surfaceId = surfaceId
        self.componentId = componentId
        self.props = props

        // Initialize state
        let resolver = DataBindingResolver()
        let dataModel = SurfaceManager().getDataModel(in: surfaceId)
        let initialValue = props.text != nil ? resolver.resolve(props.text!, in: dataModel) : ""
        _text = State(initialValue: initialValue)
    }

    var body: some View {
        let dataModel = state.surfaceManager.getDataModel(in: surfaceId)
        let label = resolver.resolve(props.label, in: dataModel)
        let variant = props.textFieldType ?? "shortText"

        let isMultiline = variant == "longText"

        Group {
            if isMultiline {
                TextEditor(text: $text)
                    .focused($isFocused)
                    .frame(minHeight: 100)
            } else {
                TextField(label, text: $text)
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .onChange(of: text) { oldValue, newValue in
            updateDataModel(newValue)
        }
        .accessibilityLabel(label)
    }

    private func updateDataModel(_ newValue: String) {
        guard let textPath = props.text else { return }

        if case .path(let path) = textPath {
            state.surfaceManager.updateDataModel(
                path: path,
                value: .string(newValue),
                in: surfaceId
            )
        }
    }
}
