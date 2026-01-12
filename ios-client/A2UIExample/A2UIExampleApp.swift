// A2UIExampleApp.swift
// A2UI Example App
//

import SwiftUI
import A2UICore
import A2UIServices
import A2UIViews

@main
struct A2UIExampleApp: App {
    @State private var appState = A2UIState()
    @State private var client: A2UIClient?
    @State private var delegate: A2UIClientDelegateImpl?

    var body: some Scene {
        WindowGroup {
            AppRootView(client: $client, delegate: $delegate, appState: appState)
        }
    }

    @MainActor
    final class A2UIClientDelegateImpl: A2UIClientDelegate {
        private let state: A2UIState
        private let resolver = DataBindingResolver()

        init(state: A2UIState) {
            self.state = state
        }

        func didReceive(message: ServerMessage) async {
            print("Receive message: \(message)")
            switch message {
            case .createSurface(let msg):
                state.createSurface(id: msg.surfaceId)
                state.currentSurfaceId = msg.surfaceId
            case .updateComponents(let msg):
                state.updateComponents(msg.components, in: msg.surfaceId)
            case .updateDataModel(let msg):
                state.updateDataModel(path: msg.path, value: msg.value, in: msg.surfaceId)
            case .deleteSurface(let msg):
                state.deleteSurface(id: msg.surfaceId)
            }
        }
    }
}

// MARK: - App Root View

@MainActor
private struct AppRootView: View {
    @Binding var client: A2UIClient?
    @Binding var delegate: A2UIExampleApp.A2UIClientDelegateImpl?
    @State private var errorMessage: String?
    let appState: A2UIState

    var body: some View {
        Group {
            if let client = client {
                A2UIMainView(client: client)
                    .environment(appState)
            } else {
                if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Initialization Failed")
                            .font(.title2)
                        Text(error)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ProgressView("Initializing...")
                }
            }
        }
        .task {
            await setupClient()
        }
    }

    private func setupClient() async {
        let baseURL = URL(string: "http://localhost:3000")!
        let newClient = A2UIClient(baseURL: baseURL)
        let newDelegate = A2UIExampleApp.A2UIClientDelegateImpl(state: appState)
        newClient.delegate = newDelegate
        self.delegate = newDelegate
        self.client = newClient

        do {
            _ = try await newClient.checkHealth()
            appState.isConnected = true
        } catch {
            appState.errorMessage = "Mock server not running. Please start it with: cd mock-server && node server.js"
            self.errorMessage = "Unable to connect to the mock server. Please ensure it's running on port 3000."
        }
    }
}

