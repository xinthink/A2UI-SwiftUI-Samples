// A2UIDividerView.swift
// A2UIViews
//
// Divider component renderer
//

import SwiftUI
import A2UICore

internal struct A2UIDividerView: View {
    let props: DividerProperties

    var body: some View {
        let axis = props.axis ?? "horizontal"

        if axis == "vertical" {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .padding(.horizontal, 8)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.vertical, 8)
        }
    }
}
