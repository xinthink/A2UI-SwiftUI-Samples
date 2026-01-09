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

        // Initialize the state
        let resolver = DataBindingResolver()
        let dataModel = SurfaceManager().getDataModel(in: surfaceId)
        let initialValue = props.value != nil ? resolver.resolve(props.value!, in: dataModel) : false
        _isChecked = State(initialValue: initialValue)
    }

    var body: some View {
        let dataModel = state.surfaceManager.getDataModel(in: surfaceId)
        let label = DataBindingResolver().resolve(props.label, in: dataModel)

        Toggle(label, isOn: $isChecked)
            .focused($isFocused)
            .onChange(of: isChecked) { oldValue, newValue in
                updateDataModel(newValue)
            }
    }

    private func updateDataModel(_ newValue: Bool) {
        guard let valueBinding = props.value else { return }

        if case .path(let path) = valueBinding {
            state.surfaceManager.updateDataModel(
                path: path,
                value: .bool(newValue),
                in: surfaceId
            )
        }
    }
}
