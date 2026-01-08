import SwiftUI
import Foundation

// MARK: - A2UI Types

struct A2UIMessage: Codable {
    let createSurface: CreateSurfaceMessage?
    let updateComponents: UpdateComponentsMessage?
    let updateDataModel: UpdateDataModelMessage?
    let deleteSurface: DeleteSurfaceMessage?
}

struct CreateSurfaceMessage: Codable {
    let surfaceId: String
    let catalogId: String?
}

struct UpdateComponentsMessage: Codable {
    let surfaceId: String
    let components: [Component]
}

struct UpdateDataModelMessage: Codable {
    let surfaceId: String
    let path: String?
    let value: AnyCodable?
}

struct DeleteSurfaceMessage: Codable {
    let surfaceId: String
}

struct Component: Codable, Identifiable {
    let id: String
    let component: String
    let weight: Double?
    let children: ChildList?
    let text: DynamicString?
    let label: DynamicString?
    let value: DynamicValue?
    let variant: String?
    let action: Action?
    let url: DynamicString?
    let name: DynamicString?
    let alignment: String?
    let distribution: String?
    let child: String?
    let contentChild: String?
    let header: String?
    let footer: String?
}

struct ChildList: Codable {
    let explicitList: [String]?
    let template: Template?

    struct Template: Codable {
        let componentId: String
        let dataBinding: DynamicValue
    }
}

enum DynamicValue: Codable {
    case string(DynamicString)
    case number(DynamicNumber)
    case boolean(DynamicBoolean)
    case stringList(DynamicStringList)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(DynamicString.self) {
            self = .string(string)
        } else if let number = try? container.decode(DynamicNumber.self) {
            self = .number(number)
        } else if let bool = try? container.decode(DynamicBoolean.self) {
            self = .boolean(bool)
        } else if let list = try? container.decode(DynamicStringList.self) {
            self = .stringList(list)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid DynamicValue")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .stringList(let value):
            try container.encode(value)
        }
    }
}

struct DynamicString: Codable {
    let literalString: String?
    let path: String?
}

struct DynamicNumber: Codable {
    let literalNumber: Double?
    let path: String?
}

struct DynamicBoolean: Codable {
    let literalBoolean: Bool?
    let path: String?
}

struct DynamicStringList: Codable {
    let literalStringList: [String]?
    let path: String?
}

struct Action: Codable {
    let name: String
    let context: [String: DynamicValue]?
}

struct UserAction: Codable {
    let action: String
    let surfaceId: String
    let context: [String: AnyCodable]?
}

class SurfaceState: ObservableObject {
    @Published var components: [String: Component] = [:]
    @Published var dataModel: [String: Any] = [:]
    let surfaceId: String

    init(surfaceId: String) {
        self.surfaceId = surfaceId
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// MARK: - Data Binding Resolver

class DataBindingResolver {
    static func resolveString(_ dynamicString: DynamicString?, dataModel: [String: Any]) -> String {
        if let literal = dynamicString?.literalString {
            return literal
        }

        if let path = dynamicString?.path {
            return resolvePath(path, dataModel) as? String ?? ""
        }

        return ""
    }

    static func resolveValue(_ dynamicValue: DynamicValue?, dataModel: [String: Any]) -> Any? {
        guard let dynamicValue = dynamicValue else { return nil }

        switch dynamicValue {
        case .string(let string):
            return resolveString(string, dataModel: dataModel)
        case .number(let number):
            if let literal = number.literalNumber {
                return literal
            }
            if let path = number.path {
                return resolvePath(path, dataModel)
            }
        case .boolean(let bool):
            if let literal = bool.literalBoolean {
                return literal
            }
            if let path = bool.path {
                return resolvePath(path, dataModel) as? Bool
            }
        case .stringList(let list):
            if let literal = list.literalStringList {
                return literal
            }
            if let path = list.path {
                return resolvePath(path, dataModel) as? [String]
            }
        }

        return nil
    }

    private static func resolvePath(_ path: String, _ dataModel: [String: Any]) -> Any? {
        // Simple JSON Pointer implementation
        var current: Any = dataModel
        let parts = path.split(separator: "/").filter { !$0.isEmpty }

        for part in parts {
            if let dict = current as? [String: Any] {
                current = dict[String(part)] ?? NSNull()
            } else if let array = current as? [Any], let index = Int(part), index < array.count {
                current = array[index]
            } else {
                return nil
            }
        }

        return current is NSNull ? nil : current
    }
}

// MARK: - A2UI Client

class A2UIClient {
    static let shared = A2UIClient()
    private let baseURL = "http://localhost:3000"

    private init() {}

    func fetchPayload(endpoint: String) async throws -> [A2UIMessage] {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw A2UIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw A2UIError.serverError
        }

        do {
            let messages = try JSONDecoder().decode([A2UIMessage].self, from: data)
            return messages
        } catch {
            print("Failed to decode A2UI messages: \(error)")
            throw A2UIError.decodingError(error.localizedDescription)
        }
    }

    func sendUserAction(_ action: UserAction) async throws {
        guard let url = URL(string: "\(baseURL)/api/action") else {
            throw A2UIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(action)
        } catch {
            throw A2UIError.encodingError(error.localizedDescription)
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw A2UIError.serverError
        }

        print("User action sent successfully")
    }
}

enum A2UIError: Error {
    case invalidURL
    case serverError
    case decodingError(String)
    case encodingError(String)
    case networkError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .serverError:
            return "Server error occurred"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .encodingError(let message):
            return "Failed to encode request: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - A2UI Renderer

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
        .background(Color(UIColor.systemBackground))
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
        if let path = template.dataBinding.path,
           let dataArray = DataBindingResolver.resolvePath(path, surfaceState.dataModel) as? [[String: Any]] {

            ForEach(dataArray.indices, id: \.self) { index in
                if let templateComponent = surfaceState.components[template.componentId] {
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

// MARK: - Content View

struct ContentView: View {
    @StateObject private var viewModel = A2UIViewModel()
    @State private var selectedExample = "Contact Form"

    let examples = ["Contact Form", "User Profile", "Todo List"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Example selector
                Picker("Select Example", selection: $selectedExample) {
                    ForEach(examples, id: \.self) { example in
                        Text(example).tag(example)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedExample) { _, newValue in
                    loadExample(newValue)
                }

                // Status view
                if viewModel.isLoading {
                    ProgressView("Loading A2UI payload...")
                        .padding()
                } else if let error = viewModel.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }

                // A2UI Renderer
                ScrollView {
                    if let surfaceState = viewModel.surfaceState {
                        A2UIRenderer(surfaceState: surfaceState)
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Select an example to load A2UI")
                                .foregroundColor(.gray)
                            Button("Load \(selectedExample)") {
                                loadExample(selectedExample)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(40)
                    }
                }

                // Action log
                if !viewModel.actionLog.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Action Log")
                            .font(.headline)
                            .padding(.horizontal)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(viewModel.actionLog, id: \.self) { log in
                                    Text(log)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("A2UI Example")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.clearSurface()
                    }) {
                        Image(systemName: "clear")
                    }
                    .disabled(viewModel.surfaceState == nil)
                }
            }
        }
        .onAppear {
            loadExample(selectedExample)
        }
    }

    private func loadExample(_ example: String) {
        let endpoint: String
        switch example {
        case "Contact Form":
            endpoint = "/api/form"
        case "User Profile":
            endpoint = "/api/profile"
        case "Todo List":
            endpoint = "/api/todos"
        default:
            endpoint = "/api/form"
        }

        viewModel.loadPayload(from: endpoint)
    }
}

class A2UIViewModel: ObservableObject {
    @Published var surfaceState: SurfaceState?
    @Published var isLoading = false
    @Published var error: String?
    @Published var actionLog: [String] = []

    func loadPayload(from endpoint: String) {
        isLoading = true
        error = nil

        Task {
            do {
                let messages = try await A2UIClient.shared.fetchPayload(endpoint: endpoint)
                await MainActor.run {
                    self.processMessages(messages)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func processMessages(_ messages: [A2UIMessage]) {
        for message in messages {
            if let createSurface = message.createSurface {
                handleCreateSurface(createSurface)
            } else if let updateComponents = message.updateComponents {
                handleUpdateComponents(updateComponents)
            } else if let updateDataModel = message.updateDataModel {
                handleUpdateDataModel(updateDataModel)
            } else if let deleteSurface = message.deleteSurface {
                handleDeleteSurface(deleteSurface)
            }
        }
    }

    private func handleCreateSurface(_ message: CreateSurfaceMessage) {
        surfaceState = SurfaceState(surfaceId: message.surfaceId)
        logAction("Created surface: \(message.surfaceId)")
    }

    private func handleUpdateComponents(_ message: UpdateComponentsMessage) {
        guard let surfaceState = surfaceState else { return }

        for component in message.components {
            surfaceState.components[component.id] = component
        }

        logAction("Updated \(message.components.count) components")
    }

    private func handleUpdateDataModel(_ message: UpdateDataModelMessage) {
        guard let surfaceState = surfaceState else { return }

        if let path = message.path, !path.isEmpty, path != "/" {
            // Update specific path
            updateDataModelAtPath(path, value: message.value?.value, in: &surfaceState.dataModel)
        } else {
            // Replace entire data model
            if let value = message.value?.value as? [String: Any] {
                surfaceState.dataModel = value
            }
        }

        logAction("Updated data model at path: \(message.path ?? "/")")
    }

    private func handleDeleteSurface(_ message: DeleteSurfaceMessage) {
        if surfaceState?.surfaceId == message.surfaceId {
            surfaceState = nil
            logAction("Deleted surface: \(message.surfaceId)")
        }
    }

    private func updateDataModelAtPath(_ path: String, value: Any?, in dataModel: inout [String: Any]) {
        let parts = path.split(separator: "/").filter { !$0.isEmpty }
        guard !parts.isEmpty else { return }

        var currentDict = dataModel

        for (index, part) in parts.enumerated() {
            let key = String(part)

            if index == parts.count - 1 {
                // Last part - set the value
                if value == nil {
                    currentDict.removeValue(forKey: key)
                } else {
                    currentDict[key] = value
                }
            } else {
                // Navigate deeper
                if var nestedDict = currentDict[key] as? [String: Any] {
                    currentDict = nestedDict
                } else {
                    // Create nested dictionary
                    let newDict: [String: Any] = [:]
                    currentDict[key] = newDict
                    currentDict = newDict
                }
            }
        }

        // Update the root if we modified the top level
        if parts.count == 1 {
            dataModel = currentDict
        }
    }

    private func logAction(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        actionLog.append("[\(timestamp)] \(message)")

        // Keep only last 10 entries
        if actionLog.count > 10 {
            actionLog.removeFirst()
        }
    }

    func clearSurface() {
        surfaceState = nil
        actionLog.removeAll()
    }
}

// MARK: - Main App

@main
struct A2UIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}