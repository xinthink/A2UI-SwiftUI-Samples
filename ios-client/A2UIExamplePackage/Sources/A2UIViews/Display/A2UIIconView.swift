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
    let contextPath: String?

    var body: some View {
        let iconName = getIconName()
        let sfSymbolName = convertToSFSymbol(iconName)

        Image(systemName: sfSymbolName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }

    private func getIconName() -> String {
        let resolver = DataBindingResolver()
        let dataModel = state.getDataModel(in: surfaceId)

        switch props.name {
        case .literalString(let value):
            return value
        case .path(let path):
            let fullPath = resolvePathWithContext(path)
            if let value = resolver.resolve(path: fullPath, in: dataModel) {
                return value.stringValue ?? ""
            }
            return ""
        }
    }

    private func resolvePathWithContext(_ path: String) -> String {
        if path.hasPrefix("/") {
            return path
        }

        if let contextPath = contextPath {
            return "\(contextPath)/\(path)"
        }

        return "/\(path)"
    }

    /// Convert common icon names to SF Symbols
    private func convertToSFSymbol(_ name: String) -> String {
        // Map common Material Icons / icon names to SF Symbols
        switch name {
        case "check_circle", "check-circle":
            return "checkmark.circle.fill"
        case "radio_button_unchecked":
            return "circle"
        case "email":
            return "envelope.fill"
        case "phone":
            return "phone.fill"
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
