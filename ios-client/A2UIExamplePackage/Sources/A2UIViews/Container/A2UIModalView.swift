// A2UIModalView.swift
// A2UIViews
//
// Modal component renderer (placeholder - uses @State for presentation)
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIModalView: View {
    @State private var isPresented = false

    let surfaceId: String
    let componentId: String
    let props: ModalProperties
    let client: A2UIClient

    var body: some View {
        VStack {
            A2UIRenderer(surfaceId: surfaceId, componentId: props.entryPointChild, client: client)
                .onTapGesture {
                    isPresented = true
                }
        }
        .sheet(isPresented: $isPresented) {
            A2UIRenderer(surfaceId: surfaceId, componentId: props.contentChild, client: client)
                .padding()
        }
    }
}
