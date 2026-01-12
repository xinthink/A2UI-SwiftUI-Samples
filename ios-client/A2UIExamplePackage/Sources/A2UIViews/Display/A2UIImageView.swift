// A2UIImageView.swift
// A2UIViews
//
// Image component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UIImageView: View {
    @Environment(A2UIState.self) private var state

    let surfaceId: String
    let props: ImageProperties
    let contextPath: String?

    var body: some View {
        let resolver = DataBindingResolver()
        let dataModel = state.getDataModel(in: surfaceId)
        let urlString = resolver.resolve(props.url, in: dataModel)

        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}
