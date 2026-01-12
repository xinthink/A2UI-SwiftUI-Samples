// A2UICheckboxView.swift
// A2UIViews
//
// Checkbox component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UICheckboxView: View {
    @Environment(A2UIState.self) private var state
    @FocusState private var isFocused: Bool

    let surfaceId: String
    let componentId: String
    let props: CheckboxProperties

    @State private var isChecked: Bool

    init(surfaceId: String, componentId: String, props: CheckboxProperties) {
        self.surfaceId = surfaceId
        self.componentId = componentId
        self.props = props

        // Initialize state
        // Note: We cannot access @Environment in init, so we initialize with default value
        // The body will update when the environment is available
        _isChecked = State(initialValue: false)
    }

    var body: some View {
        let dataModel = state.getDataModel(in: surfaceId)
        let label = DataBindingResolver().resolve(props.label, in: dataModel)

        // Initialize value from data model on first appearance
        let resolvedValue = props.value.map { DataBindingResolver().resolve($0, in: dataModel) } ?? false

        Toggle(label, isOn: $isChecked)
            .focused($isFocused)
            .onAppear {
                // Set initial value from data model
                isChecked = resolvedValue
            }
            .onChange(of: isChecked) { oldValue, newValue in
                updateDataModel(newValue)
            }
    }

    private func updateDataModel(_ newValue: Bool) {
        guard let valueBinding = props.value else { return }

        if case .path(let path) = valueBinding {
            state.updateDataModel(
                path: path,
                value: .bool(newValue),
                in: surfaceId
            )
        }
    }
}
