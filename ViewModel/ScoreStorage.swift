//
//  ScoreStorage.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 8/7/25.
//

import UIKit

class ScoreStorage {
    static let shared = ScoreStorage()
    private let scoresURL: URL
    private let obstaclesURL: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        scoresURL = docs.appendingPathComponent("savedScore.json")
        obstaclesURL = docs.appendingPathComponent("obstaclesByMap.json")
    }

    // Save general scores
    func save(_ score: SavedScore) {
        let data = try! JSONEncoder().encode(score)
        try? data.write(to: scoresURL)
    }
    func loadScore() -> SavedScore {
        guard let data = try? Data(contentsOf: scoresURL),
              let s = try? JSONDecoder().decode(SavedScore.self, from: data) else {
            return .init(starCount: 0, diamondCount: 0,
                         lifeCount: 0, shieldCount: 0,
                         magnetCount: 0, speedCount: 0)
        }
        return s
    }

    // Save obstacles per map
    func saveObstacles(_ dict: ObstaclesByMap) {
        let data = try! JSONEncoder().encode(dict)
        try? data.write(to: obstaclesURL)
    }
    func loadObstacles() -> ObstaclesByMap {
        guard let data = try? Data(contentsOf: obstaclesURL),
              let d = try? JSONDecoder().decode(ObstaclesByMap.self, from: data) else {
            return [:]
        }
        return d
    }
}
