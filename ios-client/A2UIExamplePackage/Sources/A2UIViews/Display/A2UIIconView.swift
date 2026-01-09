// A2UIIconView.swift
// A2UIViews
//
// Icon component renderer using SF Symbols
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIIconView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let props: IconProperties

    var body: some View {
        let dataModel = state.surfaceManager.getDataModel(in: surfaceId)
        let iconName = DataBindingResolver().resolve(props.name, in: dataModel)
        let sfSymbolName = convertToSFSymbol(iconName)

        Image(systemName: sfSymbolName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }

    /// Convert common icon names to SF Symbols
    private func convertToSFSymbol(_ name: String) -> String {
        // Map common Material Icons / icon names to SF Symbols
        switch name {
        case "check_circle", "check-circle":
            return "checkmark.circle.fill"
        case "email":
            return "envelope.fill"
        case "person":
            return "person.fill"
        case "home":
            return "house.fill"
        case "settings":
            return "gear"
        case "search":
            return "magnifyingglass"
        case "menu":
            return "line.3.horizontal"
        case "close", "clear":
            return "xmark"
        case "add":
            return "plus"
        case "delete":
            return "trash"
        case "edit":
            return "pencil"
        case "save":
            return "square.and.arrow.down"
        default:
            return name
        }
    }
}
