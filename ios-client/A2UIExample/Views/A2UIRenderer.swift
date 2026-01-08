import SwiftUI

struct A2UIRenderer: View {
    @ObservedObject var surfaceState: SurfaceState
    @State private var formData: [String: String] = [:]

    var body: some View {
        if let rootComponent = surfaceState.components["root"] {
            renderComponent(rootComponent)
        } else {
            Text("No UI to display")
                .foregroundColor(.gray)
                .padding()
        }
    }

    @ViewBuilder
    private func renderComponent(_ component: Component) -> some View {
        switch component.component {
        case "Column":
            renderColumn(component)
        case "Row":
            renderRow(component)
        case "Text":
            renderText(component)
        case "Button":
            renderButton(component)
        case "TextField":
            renderTextField(component)
        case "Card":
            renderCard(component)
        case "List":
            renderList(component)
        case "Image":
            renderImage(component)
        case "Icon":
            renderIcon(component)
        case "Divider":
            renderDivider(component)
        default:
            Text("Unknown component: \(component.component)")
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    private func renderColumn(_ component: Component) -> some View {
        let alignment = parseHorizontalAlignment(component.alignment)
        let distribution = parseVerticalDistribution(component.distribution)

        VStack(alignment: alignment, spacing: 8) {
            if let children = component.children?.explicitList {
                ForEach(children, id: \.self) { childId in
                    if let childComponent = surfaceState.components[childId] {
                        renderComponent(childComponent)
                    }
                }
            } else if let template = component.children?.template {
                renderTemplate(template, componentId: component.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: distribution)
    }

    @ViewBuilder
    private func renderRow(_ component: Component) -> some View {
        let alignment = parseVerticalAlignment(component.alignment)
        let distribution = parseHorizontalDistribution(component.distribution)

        HStack(alignment: alignment, spacing: 8) {
            if let children = component.children?.explicitList {
                ForEach(children, id: \.self) { childId in
                    if let childComponent = surfaceState.components[childId] {
                        renderComponent(childComponent)
                    }
                }
            } else if let template = component.children?.template {
                renderTemplate(template, componentId: component.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: distribution)
    }

    @ViewBuilder
    private func renderText(_ component: Component) -> some View {
        let text = DataBindingResolver.resolveString(component.text, dataModel: surfaceState.dataModel)
        let alignment = parseTextAlignment(component.alignment)

        Text(text)
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(.vertical, 4)
    }

    @ViewBuilder
    private func renderButton(_ component: Component) -> some View {
        let action = component.action

        Button(action: {
            handleButtonAction(action)
        }) {
            if let childId = component.child,
               let childComponent = surfaceState.components[childId] {
                renderComponent(childComponent)
            } else {
                Text("Button")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }

    @ViewBuilder
    private func renderTextField(_ component: Component) -> some View {
        let label = DataBindingResolver.resolveString(component.label, dataModel: surfaceState.dataModel)
        let fieldId = component.id
        let variant = component.variant ?? "shortText"

        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("Enter \(label)", text: bindingForField(fieldId))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)

            if variant == "longText" {
                EmptyView()
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func renderCard(_ component: Component) -> some View {
        let contentChildId = component.contentChild

        VStack {
            if let contentChildId = contentChildId,
               let contentComponent = surfaceState.components[contentChildId] {
                renderComponent(contentComponent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func renderList(_ component: Component) -> some View {
        if let template = component.children?.template {
            renderTemplate(template, componentId: component.id)
        }
    }

    @ViewBuilder
    private func renderImage(_ component: Component) -> some View {
        let urlString = DataBindingResolver.resolveString(component.url, dataModel: surfaceState.dataModel)

        if let url = URL(string: urlString), !urlString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
        } else {
            Image(systemName: "photo")
                .foregroundColor(.gray)
                .frame(width: 100, height: 100)
        }
    }

    @ViewBuilder
    private func renderIcon(_ component: Component) -> some View {
        let iconName = DataBindingResolver.resolveString(component.name, dataModel: surfaceState.dataModel)
        let systemName = mapIconName(iconName)

        Image(systemName: systemName)
            .foregroundColor(.blue)
            .frame(width: 24, height: 24)
    }

    @ViewBuilder
    private func renderDivider(_ component: Component) -> some View {
        Divider()
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private func renderTemplate(_ template: ChildList.Template, componentId: String) -> some View {
        if let dataArray = DataBindingResolver.resolveValue(
            .stringList(DynamicStringList(path: template.dataBinding.path)),
            dataModel: surfaceState.dataModel
        ) as? [[String: Any]] {

            ForEach(dataArray.indices, id: \.self) { index in
                if let templateComponent = surfaceState.components[template.componentId] {
                    // Create a temporary state with the item's data
                    // This is a simplified implementation
                    renderComponent(templateComponent)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func bindingForField(_ fieldId: String) -> Binding<String> {
        Binding(
            get: {
                formData[fieldId] ?? ""
            },
            set: { newValue in
                formData[fieldId] = newValue
            }
        )
    }

    private func handleButtonAction(_ action: Action?) {
        guard let action = action else { return }

        let userAction = UserAction(
            action: action.name,
            surfaceId: surfaceState.surfaceId,
            context: action.context?.mapValues { dynamicValue in
                AnyCodable(DataBindingResolver.resolveValue(dynamicValue, dataModel: surfaceState.dataModel) ?? NSNull())
            }
        )

        Task {
            do {
                try await A2UIClient.shared.sendUserAction(userAction)
                print("Action sent successfully: \(action.name)")
            } catch {
                print("Failed to send action: \(error)")
            }
        }
    }

    private func parseHorizontalAlignment(_ alignment: String?) -> HorizontalAlignment {
        switch alignment {
        case "start": return .leading
        case "center": return .center
        case "end": return .trailing
        default: return .leading
        }
    }

    private func parseVerticalAlignment(_ alignment: String?) -> VerticalAlignment {
        switch alignment {
        case "start": return .top
        case "center": return .center
        case "end": return .bottom
        default: return .center
        }
    }

    private func parseTextAlignment(_ alignment: String?) -> Alignment {
        switch alignment {
        case "start": return .leading
        case "center": return .center
        case "end": return .trailing
        default: return .leading
        }
    }

    private func parseHorizontalDistribution(_ distribution: String?) -> Alignment {
        switch distribution {
        case "start": return .leading
        case "center": return .center
        case "end": return .trailing
        default: return .leading
        }
    }

    private func parseVerticalDistribution(_ distribution: String?) -> Alignment {
        switch distribution {
        case "start": return .top
        case "center": return .center
        case "end": return .bottom
        default: return .top
        }
    }

    private func mapIconName(_ name: String) -> String {
        switch name {
        case "email": return "envelope"
        case "phone": return "phone"
        case "check_circle": return "checkmark.circle"
        case "radio_button_unchecked": return "circle"
        case "delete": return "trash"
        default: return name
        }
    }
}