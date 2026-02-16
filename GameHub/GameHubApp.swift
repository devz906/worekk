//
//  GameHubApp.swift
//  GameHub
//
//  GameHub for iPhone 16 Pro – JIT-enabled PC/Windows game container runner.
//  Use with StikJIT (sideload) for best speed. See PORT_PLAN.md and README.
//

import SwiftUI

@main
struct GameHubApp: App {
    @StateObject private var containerManager = ContainerManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(containerManager)
        }
    }
}
