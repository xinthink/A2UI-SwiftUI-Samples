// A2UIButtonView.swift
// A2UIViews
//
// Button component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIButtonView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let componentId: String
    let props: ButtonProperties
    let client: A2UIClient
    let contextPath: String?

    var body: some View {
        let isPrimary = props.primary ?? false

        Button(action: {
            Task {
                await handleAction()
            }
        }) {
            A2UIRenderer(
                surfaceId: surfaceId,
                componentId: props.child,
                client: client,
                contextPath: contextPath
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(A2UIButtonStyle(primary: isPrimary))
    }

    private func handleAction() async {
        let action = props.action
        let dataModel = state.getDataModel(in: surfaceId)
        let resolver = DataBindingResolver()

        // Resolve action context with current data model
        var resolvedContext: [String: JSONValue] = [:]
        if let context = action.context {
            for (key, value) in context {
                let fullPath = resolvePathWithContext(value)
                if let jsonValue = resolver.resolve(path: fullPath, in: dataModel) {
                    resolvedContext[key] = jsonValue
                } else {
                    // Fallback to resolving as DynamicString
                    let stringValue = resolveString(value, dataModel: dataModel)
                    resolvedContext[key] = .string(stringValue)
                }
            }
        }

        let clientAction = ClientAction(
            action: action.name,
            surfaceId: surfaceId,
            context: resolvedContext.isEmpty ? nil : resolvedContext
        )

        do {
            try await client.sendAction(clientAction)
        } catch {
            state.errorMessage = "Failed to send action: \(error.localizedDescription)"
        }
    }

    private func resolvePathWithContext(_ dynamicString: DynamicString) -> String {
        switch dynamicString {
        case .literalString:
            return "" // Not a path
        case .path(let path):
            if path.hasPrefix("/") {
                return path
            }
            if let contextPath = contextPath {
                return "\(contextPath)/\(path)"
            }
            return "/\(path)"
        }
    }

    private func resolveString(_ dynamicString: DynamicString, dataModel: [String: JSONValue]) -> String {
        switch dynamicString {
        case .literalString(let value):
            return value
        case .path(let path):
            let fullPath = resolvePathWithContext(dynamicString)
            let resolver = DataBindingResolver()
            if let value = resolver.resolve(path: fullPath, in: dataModel) {
                return value.stringValue ?? ""
            }
            return ""
        }
    }
}

// MARK: - Button Style

struct A2UIButtonStyle: ButtonStyle {
    let primary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(primary ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundColor(primary ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
