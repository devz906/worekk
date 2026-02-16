//
//  GameContainer.swift
//  GameHub
//

import Foundation

struct GameContainer: Identifiable, Codable, Equatable {
    var id: String { path }
    let name: String
    let path: String
    let importedAt: Date

    init(name: String, path: String, importedAt: Date = Date()) {
        self.name = name
        self.path = path
        self.importedAt = importedAt
    }
}
