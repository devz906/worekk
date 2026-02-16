//
//  GameEntry.swift
//  GameHub
//

import Foundation

struct GameEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let exePath: String
    let containerId: String
    let containerName: String
    let iconName: String

    init(id: UUID = UUID(), name: String, exePath: String, containerId: String, containerName: String, iconName: String = "play.circle.fill") {
        self.id = id
        self.name = name
        self.exePath = exePath
        self.containerId = containerId
        self.containerName = containerName
        self.iconName = iconName
    }

    enum CodingKeys: String, CodingKey {
        case id, name, exePath, containerId, containerName, iconName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        exePath = try c.decode(String.self, forKey: .exePath)
        containerId = try c.decode(String.self, forKey: .containerId)
        containerName = try c.decode(String.self, forKey: .containerName)
        iconName = try c.decodeIfPresent(String.self, forKey: .iconName) ?? "play.circle.fill"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(exePath, forKey: .exePath)
        try c.encode(containerId, forKey: .containerId)
        try c.encode(containerName, forKey: .containerName)
        try c.encode(iconName, forKey: .iconName)
    }
}
