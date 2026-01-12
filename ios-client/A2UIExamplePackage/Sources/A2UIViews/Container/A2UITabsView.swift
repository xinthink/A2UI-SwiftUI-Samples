// A2UITabsView.swift
// A2UIViews
//
// Tabs component renderer
//

import SwiftUI
import A2UICore
import A2UIServices

internal struct A2UITabsView: View {
    @Environment(A2UIState.self) private var state
    @State private var selection: String?

    let surfaceId: String
    let componentId: String
    let props: TabsProperties
    let client: A2UIClient

    var body: some View {
        let dataModel = state.getDataModel(in: surfaceId)
        let firstTab = props.tabItems.first?.child
        let selected = selection ?? firstTab

        TabView(selection: $selection) {
            ForEach(props.tabItems, id: \.child) { tab in
                A2UIRenderer(surfaceId: surfaceId, componentId: tab.child, client: client)
                    .tabItem {
                        let title = DataBindingResolver().resolve(tab.title, in: dataModel)
                        Text(title)
                    }
                    .tag(tab.child as String?)
            }
        }
    }
}
