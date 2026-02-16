//
//  GameLibraryView.swift
//  GameHub
//

import SwiftUI

struct GameLibraryView: View {
    @EnvironmentObject var containerManager: ContainerManager

    var body: some View {
        NavigationStack {
            Group {
                if containerManager.installedGames.isEmpty {
                    ContentUnavailableView(
                        "No Games Yet",
                        systemImage: "gamecontroller",
                        description: Text("Add a BoxedWine container (boxedwine.zip) from the Containers tab, then launch your .exe from here.")
                    )
                } else {
                    List {
                        ForEach(containerManager.installedGames) { game in
                            GameRowView(game: game) {
                                containerManager.launch(game: game)
                            }
                        }
                        .onDelete(perform: containerManager.removeGames)
                    }
                }
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if !containerManager.installedGames.isEmpty {
                        EditButton()
                    }
                }
            }
        }
    }
}

struct GameRowView: View {
    let game: GameEntry
    let onLaunch: () -> Void

    var body: some View {
        HStack {
            Image(systemName: game.iconName)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.headline)
                Text(game.containerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Play", action: onLaunch)
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GameLibraryView()
            .environmentObject(ContainerManager.shared)
    }
}
