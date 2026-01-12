// A2UIMainView.swift
//
// Main view with navigation menu for examples
//

import SwiftUI
import A2UICore
import A2UIServices
import A2UIViews

struct A2UIMainView: View {
    @Environment(A2UIState.self) private var state

    let client: A2UIClient
    @State private var selectedExample: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Connection Status") {
                    if state.isConnected {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        if let error = state.errorMessage {
                            Label(error, systemImage: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                        } else {
                            Label("Connecting...", systemImage: "network")
                        }
                    }
                }

                Section("Examples") {
                    NavigationLink("Contact Form", value: "form")
                    NavigationLink("User Profile", value: "profile")
                    NavigationLink("Todo List", value: "todos")
                }
            }
            .navigationTitle("A2UI Examples")
            .navigationDestination(for: String.self) { example in
                A2UIExampleView(example: example, client: client)
            }
        }
    }
}

// MARK: - Example View

struct A2UIExampleView: View {
    let example: String
    let client: A2UIClient

    @Environment(A2UIState.self) private var state
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    ProgressView("Loading example...")
                        .padding()
                } else if let surfaceId = state.currentSurfaceId {
                    A2UIRenderer(surfaceId: surfaceId, componentId: nil, client: client)
                        .padding()
                } else {
                    ContentUnavailableView(
                        "No Surface",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Could not load the example. Make sure the mock server is running.")
                    )
                }
            }
        }
        .navigationTitle(example.capitalized + " Example")
        .task {
            await loadExample()
        }
    }

    private func loadExample() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await client.fetchSurface(from: "/api/\(example)")
        } catch {
            state.errorMessage = "Failed to load example: \(error.localizedDescription)"
        }
    }
}
