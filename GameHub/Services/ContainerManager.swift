//
//  ContainerManager.swift
//  GameHub
//
//  Manages BoxedWine-style containers (e.g. boxedwine.zip) and game entries.
//  When BoxedWine iOS port is ready, launch() will invoke the native runner.
//

import Foundation
import SwiftUI

@MainActor
final class ContainerManager: ObservableObject {
    static let shared = ContainerManager()

    @Published private(set) var containers: [GameContainer] = []
    @Published private(set) var installedGames: [GameEntry] = []
    @Published private(set) var canImport = true

    private let containerKey = "gamehub.containers"
    private let gamesKey = "gamehub.games"
    private let fileManager = FileManager.default

    private var containersDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appending(path: "Containers", directoryHint: .isDirectory)
    }

    init() {
        loadContainers()
        loadGames()
        ensureContainersDirectory()
    }

    private func ensureContainersDirectory() {
        guard let dir = containersDirectory else { return }
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    private func loadContainers() {
        guard let data = UserDefaults.standard.data(forKey: containerKey),
              let decoded = try? JSONDecoder().decode([GameContainer].self, from: data) else { return }
        containers = decoded
    }

    private func saveContainers() {
        guard let data = try? JSONEncoder().encode(containers) else { return }
        UserDefaults.standard.set(data, forKey: containerKey)
    }

    private func loadGames() {
        guard let data = UserDefaults.standard.data(forKey: gamesKey),
              let decoded = try? JSONDecoder().decode([GameEntry].self, from: data) else { return }
        installedGames = decoded
    }

    private func saveGames() {
        guard let data = try? JSONEncoder().encode(installedGames) else { return }
        UserDefaults.standard.set(data, forKey: gamesKey)
    }

    func importContainer(from url: URL, completion: @escaping (String) -> Void) {
        guard let destDir = containersDirectory else {
            completion("No documents directory.")
            return
        }
        let name = url.deletingPathExtension().lastPathComponent
        let dest: URL
        if url.pathExtension.lowercased() == "zip" {
            dest = destDir.appending(path: url.lastPathComponent, directoryHint: .notDirectory)
        } else {
            dest = destDir.appending(path: name, directoryHint: .isDirectory)
        }

        do {
            if fileManager.fileExists(atPath: dest.path) {
                try fileManager.removeItem(at: dest)
            }
            try fileManager.copyItem(at: url, to: dest)
            let container = GameContainer(name: name, path: dest.path)
            if !containers.contains(where: { $0.path == dest.path }) {
                containers.append(container)
                saveContainers()
            }
            completion("Imported: \(name)")
        } catch {
            completion("Import failed: \(error.localizedDescription)")
        }
    }

    func removeContainers(at offsets: IndexSet) {
        let removedPaths = Set(offsets.map { containers[$0].path })
        for index in offsets {
            try? fileManager.removeItem(atPath: containers[index].path)
        }
        containers.remove(atOffsets: offsets)
        installedGames.removeAll { removedPaths.contains($0.containerId) }
        saveContainers()
        saveGames()
    }

    func addGame(name: String, exePath: String, containerId: String, containerName: String) {
        let entry = GameEntry(name: name, exePath: exePath, containerId: containerId, containerName: containerName)
        installedGames.append(entry)
        saveGames()
    }

    func removeGames(at offsets: IndexSet) {
        installedGames.remove(atOffsets: offsets)
        saveGames()
    }

    /// Launches the game. When BoxedWine iOS runner is integrated, call into native code here.
    func launch(game: GameEntry) {
        // TODO: Integrate BoxedWine iOS port – run container at game.containerId, exe at game.exePath
        // For now we only show that the action was triggered; no native runner yet.
        #if DEBUG
        print("Launch: \(game.name) @ \(game.exePath) in \(game.containerId)")
        #endif
    }
}

// BoxedWine can load filesystem from a .zip (BOXEDWINE_ZLIB); we store the .zip path and pass it to the runner when ported.
