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

    let surfaceId: String
    let props: TextProperties
    let contextPath: String?

    var body: some View {
        let text = getText()
        let alignment = resolveAlignment(props.alignment)

        Text(text)
            .multilineTextAlignment(alignment)
            .accessibilityLabel("Text: \(text)")
    }

    private func getText() -> String {
        let resolver = DataBindingResolver()
        let dataModel = state.getDataModel(in: surfaceId)
        return resolveText(resolver: resolver, dataModel: dataModel)
    }

    private func resolveText(resolver: DataBindingResolver, dataModel: [String: JSONValue]) -> String {
        switch props.text {
        case .literalString(let value):
            return value
        case .path(let path):
            // Handle relative paths with context
            let fullPath = resolvePathWithContext(path)
            if let value = resolver.resolve(path: fullPath, in: dataModel) {
                return value.stringValue ?? ""
            }
            return ""
        }
    }

    private func resolvePathWithContext(_ path: String) -> String {
        // If path is absolute (starts with /), use it as-is
        if path.hasPrefix("/") {
            return path
        }

        // If path is relative and we have a context, prepend the context path
        if let contextPath = contextPath {
            return "\(contextPath)/\(path)"
        }

        // Otherwise, treat relative path as root-level
        return "/\(path)"
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
