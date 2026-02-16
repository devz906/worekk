//
//  SettingsView.swift
//  GameHub
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Device", value: "iPhone 16 Pro")
                    LabeledContent("JIT", value: "Enable via StikJIT (sideload)")
                } header: {
                    Text("Optimized for")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For best speed (Wine / BoxedWine emulation), this app should run with JIT enabled.")
                            .font(.subheadline)
                        Text("• Install via sideload (AltStore, SideStore, or Xcode).")
                        Text("• Use StikJIT to enable JIT: stikjit.github.io")
                        Text("• Supported: iOS 17.4–18.7.4 (check StikJIT for latest).")
                        Text("• App Store builds cannot use JIT.")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } header: {
                    Text("JIT (StikJIT)")
                }

                Section {
                    Link("StikJIT – Enable JIT", destination: URL(string: "https://stikjit.github.io")!)
                    Link("BoxedWine", destination: URL(string: "https://www.boxedwine.org")!)
                    Link("MoltenVK (Vulkan on Metal)", destination: URL(string: "https://github.com/The-Wineskin-Project/MoltenVK")!)
                } header: {
                    Text("Links")
                }

                Section {
                    Text("GameHub uses BoxedWine-style containers (e.g. boxedwine.zip) to run Windows .exe. GPU path: DXVK → MoltenVK → Metal. See PORT_PLAN.md in the project.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Stack")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
