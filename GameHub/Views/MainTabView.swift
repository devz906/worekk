//
//  MainTabView.swift
//  GameHub
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GameLibraryView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(0)

            ContainerListView()
                .tabItem {
                    Label("Containers", systemImage: "archivebox.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.accentColor)
    }
}

#Preview {
    MainTabView()
        .environmentObject(ContainerManager.shared)
}
