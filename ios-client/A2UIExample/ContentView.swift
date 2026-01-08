import SwiftUI

// Import shared types
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
                .onChange(of: selectedExample) { newValue in
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

        var current: Any = dataModel
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
                    var newDict: [String: Any] = [:]
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