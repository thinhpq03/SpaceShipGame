//
//  SavedScore.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 8/7/25.
//

import Foundation

struct SavedScore: Codable {
    var starCount: Int
    var diamondCount: Int
    var lifeCount: Int
    var shieldCount: Int
    var magnetCount: Int
    var speedCount: Int
}

typealias ObstaclesByMap = [Int: Int]
