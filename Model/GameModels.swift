//
//  GameModels.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 7/7/25.
//

import UIKit

// MARK: - Enums
enum MapPlay {
    case map_1, map_2, map_3, map_4
}

enum GameObjectType {
    case obstacle(String)
    case reward(String)
}

enum GameState {
    case waiting
    case playing
    case gameOver
}

enum PowerUpType {
    case speed
    case shield
    case magnet
}

// MARK: - Models
struct GameConfig {
    let gravity: CGFloat = 800
    let jumpVelocity: CGFloat = -300
    let objectSpeed: CGFloat = 150
    let objectSpawnInterval: CFTimeInterval = 2.0
    let minSpawnInterval: CFTimeInterval = 0.8
    let maxSpaceshipSize: CGFloat = 150
    let difficultyRampTime: CFTimeInterval = 30.0
}

struct GameScore {
    var obstaclesPassed: Int = 0
    var starCount: Int = 0
    var diamondCount: Int = 0

    mutating func reset() {
        obstaclesPassed = 0
        starCount = 0
        diamondCount = 0
    }
}

struct SpaceshipState {
    var position: CGPoint
    var velocityY: CGFloat = 0
    var size: CGSize

    mutating func reset(to position: CGPoint) {
        self.position = position
        self.velocityY = 0
    }
}

class GameObject: UIImageView {
    let type: GameObjectType
    var passed = false

    init(type: GameObjectType) {
        self.type = type
        let imageName: String
        switch type {
            case .obstacle(let name):
                imageName = name
            case .reward(let name):
                imageName = name
        }
        super.init(image: UIImage(named: imageName))
        self.contentMode = .scaleAspectFit
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - GameViewModel
protocol GameViewModelDelegate: AnyObject {
    func gameDidStart()
    func gameDidEnd(with score: GameScore)
    func spaceshipDidMove(to position: CGPoint)
    func didSpawnObject(_ object: GameObject)
    func didRemoveObject(_ object: GameObject)
    func scoreDidUpdate(_ score: GameScore)
    func powerUpDidActivate(_ type: PowerUpType, duration: CFTimeInterval)
    func powerUpDidExpire(_ type: PowerUpType)

    // Pause system
    func gameDidPause()
    func gameDidResume()

    // Life system
    func lifeDidDecrease(newCount: Int)
    func invulnerabilityDidStart()
    func invulnerabilityDidEnd()

    func updateLifeDisplay(_ count: Int)
}
