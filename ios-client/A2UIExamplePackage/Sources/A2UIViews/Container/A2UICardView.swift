// A2UICardView.swift
// A2UIViews
//
// Card component renderer (placeholder)
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UICardView: View {
    let surfaceId: String
    let componentId: String
    let props: CardProperties
    let client: A2UIClient

    var body: some View {
        A2UIRenderer(surfaceId: surfaceId, componentId: props.child, client: client)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
}
