//
//  GameViewModel.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 7/7/25.
//

import CoreFoundation
import UIKit

class GameViewModel {
    // MARK: - Properties
    weak var delegate: GameViewModelDelegate?

    private let config = GameConfig()
    private var gameState: GameState = .waiting
    private var gameScore = GameScore()
    private var spaceshipState: SpaceshipState
    private var gameObjects: [GameObject] = []

    // Timing
    private var gameStartTime: CFTimeInterval = 0
    private var lastObjectSpawnTime: CFTimeInterval = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var pausedTime: CFTimeInterval = 0 // Track total paused time

    // Screen bounds
    private var screenBounds: CGRect
    private var mapId: Int

    // MARK: - Power-up Properties
    private var speedPowerUpActive = false
    private var speedPowerUpStartTime: CFTimeInterval = 0
    private let speedPowerUpDuration: CFTimeInterval = 30.0
    private let speedPowerUpMultiplier: CGFloat = 0.5

    // Shield power-up
    private var shieldActive = false
    private var shieldHits = 0
    private let maxShieldHits = 1

    // Magnet power-up
    private var magnetActive = false
    private var magnetStartTime: CFTimeInterval = 0
    private let magnetDuration: CFTimeInterval = 15.0
    private let magnetRange: CGFloat = 150.0

    // MARK: - Life System Properties
    private var lifeCount: Int = 0
    private var isInvulnerable = false
    private var invulnerabilityStartTime: CFTimeInterval = 0
    private let invulnerabilityDuration: CFTimeInterval = 2.0

    // MARK: - Pause System Properties
    private var isPaused = false
    private var pauseStartTime: CFTimeInterval = 0

    // MARK: - Initialization
    init(screenBounds: CGRect, mapId: Int) {
        self.screenBounds = screenBounds

        // Use selected spaceship from SpaceshipManager
        let spaceshipImageName = SpaceshipManager.shared.selectedSpaceshipImageName

        // Calculate spaceship size
        let spaceshipSize = Self.calculateSpaceshipSize(
            imageName: spaceshipImageName,
            maxSize: config.maxSpaceshipSize
        )

        self.spaceshipState = SpaceshipState(
            position: CGPoint(x: screenBounds.midX, y: screenBounds.midY),
            size: spaceshipSize
        )

        self.mapId = mapId

        // Load life count from storage
        let saved = ScoreStorage.shared.loadScore()
        self.lifeCount = saved.lifeCount
    }

    // MARK: - Public Methods
    func startGame() {
        guard gameState == .waiting else { return }

        gameState = .playing
        gameStartTime = CACurrentMediaTime()
        lastTimestamp = gameStartTime
        delegate?.gameDidStart()
    }

    func jump() {
        guard gameState == .playing && !isPaused else { return }
        spaceshipState.velocityY = config.jumpVelocity
    }

    // MARK: - Pause System Methods
    func pauseGame() {
        guard gameState == .playing && !isPaused else { return }
        isPaused = true
        pauseStartTime = CACurrentMediaTime()
        delegate?.gameDidPause()
    }

    func resumeGame() {
        guard gameState == .playing && isPaused else { return }

        let pauseDuration = CACurrentMediaTime() - pauseStartTime
        pausedTime += pauseDuration

        // Adjust all time-based tracking
        gameStartTime += pauseDuration
        lastObjectSpawnTime += pauseDuration
        lastTimestamp += pauseDuration

        // Adjust power-up timers
        if speedPowerUpActive {
            speedPowerUpStartTime += pauseDuration
        }
        if magnetActive {
            magnetStartTime += pauseDuration
        }
        if isInvulnerable {
            invulnerabilityStartTime += pauseDuration
        }

        isPaused = false
        delegate?.gameDidResume()
    }

    func getIsPaused() -> Bool {
        return isPaused
    }

    // MARK: - Life System Methods
    func getCurrentLifeCount() -> Int {
        return lifeCount
    }

    func getIsInvulnerable() -> Bool {
        return isInvulnerable
    }

    private func useLife() {
        // Sync lại lifeCount từ storage trước khi kiểm tra
        let saved = ScoreStorage.shared.loadScore()
        self.lifeCount = saved.lifeCount

        // Nếu chỉ còn 1 life, game over luôn mà không trừ life
        if lifeCount <= 1 {
            gameOver()
            return
        }

        // Còn nhiều hơn 1 life thì mới trừ
        lifeCount -= 1

        // Save updated life count
        var updatedSaved = saved
        updatedSaved.lifeCount = lifeCount
        ScoreStorage.shared.save(updatedSaved)

        // Reset spaceship position and make invulnerable
        spaceshipState.position = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        spaceshipState.velocityY = 0

        isInvulnerable = true
        invulnerabilityStartTime = CACurrentMediaTime()

        delegate?.spaceshipDidMove(to: spaceshipState.position)
        delegate?.lifeDidDecrease(newCount: lifeCount)
        delegate?.invulnerabilityDidStart()
    }

    // MARK: - Power-up Methods
    func activateSpeedPowerUp() -> Bool {
        guard gameState == .playing && !speedPowerUpActive else { return false }

        speedPowerUpActive = true
        speedPowerUpStartTime = CACurrentMediaTime()

        delegate?.powerUpDidActivate(.speed, duration: speedPowerUpDuration)
        return true
    }

    func activateShieldPowerUp() -> Bool {
        guard gameState == .playing && !shieldActive else { return false }

        shieldActive = true
        shieldHits = 0

        delegate?.powerUpDidActivate(.shield, duration: 0)
        return true
    }

    func activateMagnetPowerUp() -> Bool {
        guard gameState == .playing && !magnetActive else { return false }

        magnetActive = true
        magnetStartTime = CACurrentMediaTime()

        delegate?.powerUpDidActivate(.magnet, duration: magnetDuration)
        return true
    }

    func getSpeedPowerUpTimeRemaining() -> CFTimeInterval {
        guard speedPowerUpActive else { return 0 }

        let elapsed = CACurrentMediaTime() - speedPowerUpStartTime
        let remaining = speedPowerUpDuration - elapsed
        return max(0, remaining)
    }

    func getMagnetPowerUpTimeRemaining() -> CFTimeInterval {
        guard magnetActive else { return 0 }

        let elapsed = CACurrentMediaTime() - magnetStartTime
        let remaining = magnetDuration - elapsed
        return max(0, remaining)
    }

    func isShieldActive() -> Bool {
        return shieldActive
    }

    func update(timestamp: CFTimeInterval) {
        guard gameState == .playing && !isPaused else { return }

        let dt = CGFloat(timestamp - lastTimestamp)
        lastTimestamp = timestamp

        // Skip first frame if dt is too large
        if dt > 0.1 { return }

        updateInvulnerability(currentTime: timestamp)
        updatePowerUps(currentTime: timestamp)
        updateSpaceship(dt: dt)
        spawnObjects(currentTime: timestamp)
        updateObjects(dt: dt)

        if !isInvulnerable {
            checkCollisions()
        }

        checkGameOver()
    }

    func restartGame() {
        gameState = .waiting
        gameScore.reset()
        spaceshipState.reset(to: CGPoint(x: screenBounds.midX, y: screenBounds.midY))

        // Reset power-ups
        speedPowerUpActive = false
        speedPowerUpStartTime = 0
        shieldActive = false
        shieldHits = 0
        magnetActive = false
        magnetStartTime = 0

        // Reset life system
        let saved = ScoreStorage.shared.loadScore()
        lifeCount = saved.lifeCount
        isInvulnerable = false
        invulnerabilityStartTime = 0

        // Reset pause system
        isPaused = false
        pauseStartTime = 0
        pausedTime = 0

        // Remove all objects
        for object in gameObjects {
            delegate?.didRemoveObject(object)
        }
        gameObjects.removeAll()

        // Reset timing
        gameStartTime = 0
        lastObjectSpawnTime = 0

        delegate?.scoreDidUpdate(gameScore)
    }

    func getSpaceshipSize() -> CGSize {
        return spaceshipState.size
    }

    func getCurrentScore() -> GameScore {
        return gameScore
    }

    func getGameState() -> GameState {
        return gameState
    }

    func syncLifeCount() {
        let saved = ScoreStorage.shared.loadScore()
        self.lifeCount = saved.lifeCount
    }

    func getSelectedSpaceshipImageName() -> String {
        return SpaceshipManager.shared.selectedSpaceshipImageName
    }

    // MARK: - Private Methods
    private func updateInvulnerability(currentTime: CFTimeInterval) {
        if isInvulnerable {
            let elapsed = currentTime - invulnerabilityStartTime
            if elapsed >= invulnerabilityDuration {
                isInvulnerable = false
                delegate?.invulnerabilityDidEnd()
            }
        }
    }

    private func updatePowerUps(currentTime: CFTimeInterval) {
        // Check speed power-up expiration
        if speedPowerUpActive {
            let elapsed = currentTime - speedPowerUpStartTime
            if elapsed >= speedPowerUpDuration {
                speedPowerUpActive = false
                delegate?.powerUpDidExpire(.speed)
            }
        }

        // Check magnet power-up expiration
        if magnetActive {
            let elapsed = currentTime - magnetStartTime
            if elapsed >= magnetDuration {
                magnetActive = false
                delegate?.powerUpDidExpire(.magnet)
            }
        }
    }

    private func updateSpaceship(dt: CGFloat) {
        // Apply gravity
        spaceshipState.velocityY += config.gravity * dt

        // Update position
        var newY = spaceshipState.position.y + spaceshipState.velocityY * dt
        let halfH = spaceshipState.size.height / 2

        // Keep within screen bounds
        newY = min(max(newY, halfH), screenBounds.height - halfH)
        spaceshipState.position.y = newY

        delegate?.spaceshipDidMove(to: spaceshipState.position)
    }

    private func spawnObjects(currentTime: CFTimeInterval) {
        let gameTime = currentTime - gameStartTime
        let difficultyFactor = min(gameTime / config.difficultyRampTime, 1.0)
        let currentSpawnInterval = config.objectSpawnInterval - (config.objectSpawnInterval - config.minSpawnInterval) * difficultyFactor

        if currentTime - lastObjectSpawnTime > currentSpawnInterval {
            lastObjectSpawnTime = currentTime

            let randomValue = Int.random(in: 1...100)

            if randomValue <= 60 {
                spawnObstacle()
            } else if randomValue <= 85 {
                spawnReward()
            } else {
                spawnRandomObstacle()
            }
        }
    }

    private func spawnObstacle() {
        let obstacle = GameObject(type: .obstacle("ingame_\(mapId)"))
        obstacle.frame.size = CGSize(width: 190, height: 90)
        obstacle.contentMode = .scaleToFill

        let randomY = CGFloat.random(in: 80...(screenBounds.height - 80))
        obstacle.center = CGPoint(x: screenBounds.width + obstacle.bounds.width/2, y: randomY)

        gameObjects.append(obstacle)
        delegate?.didSpawnObject(obstacle)
    }

    private func spawnReward() {
        let rewardType = Bool.random() ? "star" : "diamond"
        let reward = GameObject(type: .reward(rewardType))
        reward.frame.size = CGSize(width: 50, height: 50)

        let randomY = CGFloat.random(in: 60...(screenBounds.height - 60))
        reward.center = CGPoint(x: screenBounds.width + reward.bounds.width/2, y: randomY)

        gameObjects.append(reward)
        delegate?.didSpawnObject(reward)
    }

    private func spawnRandomObstacle() {
        let randomNum = Int.random(in: 1...3)
        let obstacle = GameObject(type: .obstacle("random_\(randomNum)"))
        obstacle.frame.size = CGSize(width: 150, height: 150)

        let randomY = CGFloat.random(in: 80...(screenBounds.height - 80))
        obstacle.center = CGPoint(x: screenBounds.width + obstacle.bounds.width/2, y: randomY)

        gameObjects.append(obstacle)
        delegate?.didSpawnObject(obstacle)
    }

    private func updateObjects(dt: CGFloat) {
        var objectsToRemove: [GameObject] = []

        // Calculate current object speed (apply speed power-up if active)
        let currentObjectSpeed = speedPowerUpActive ?
        config.objectSpeed * speedPowerUpMultiplier :
        config.objectSpeed

        for object in gameObjects {
            // Apply magnet effect to rewards
            if magnetActive, case .reward(_) = object.type {
                applyMagnetEffect(to: object, dt: dt)
            }

            // Move object from right to left with modified speed
            object.center.x -= currentObjectSpeed * dt

            // Check if object passed spaceship
            if !object.passed && object.center.x < spaceshipState.position.x {
                object.passed = true
                if case .obstacle(_) = object.type {
                    gameScore.obstaclesPassed += 1
                    delegate?.scoreDidUpdate(gameScore)
                }
            }

            // Remove object if it's off screen
            if object.center.x < -object.bounds.width/2 {
                objectsToRemove.append(object)
            }
        }

        // Remove objects
        for object in objectsToRemove {
            gameObjects.removeAll { $0 === object }
            delegate?.didRemoveObject(object)
        }
    }

    private func applyMagnetEffect(to object: GameObject, dt: CGFloat) {
        let dx = spaceshipState.position.x - object.center.x
        let dy = spaceshipState.position.y - object.center.y
        let distance = sqrt(dx * dx + dy * dy)

        // Apply magnet force if within range
        if distance <= magnetRange && distance > 0 {
            let magnetForce: CGFloat = 200.0
            let normalizedDx = dx / distance
            let normalizedDy = dy / distance

            object.center.x += normalizedDx * magnetForce * dt
            object.center.y += normalizedDy * magnetForce * dt
        }
    }

    private func checkCollisions() {
        let spaceshipFrame = CGRect(
            x: spaceshipState.position.x - spaceshipState.size.width/2,
            y: spaceshipState.position.y - spaceshipState.size.height/2,
            width: spaceshipState.size.width,
            height: spaceshipState.size.height
        )

        var objectsToRemove: [GameObject] = []

        for object in gameObjects {
            if spaceshipFrame.intersects(object.frame) {
                switch object.type {
                    case .obstacle(_):
                        if shieldActive {
                            // Shield absorbs the hit
                            shieldHits += 1
                            if shieldHits >= maxShieldHits {
                                shieldActive = false
                                delegate?.powerUpDidExpire(.shield)
                            }
                            objectsToRemove.append(object)
                        } else {
                            // Use a life
                            useLife()
                            objectsToRemove.append(object)
                            return
                        }
                    case .reward(let rewardType):
                        if rewardType == "star" {
                            gameScore.starCount += 1
                        } else if rewardType == "diamond" {
                            gameScore.diamondCount += 1
                        }
                        objectsToRemove.append(object)
                        delegate?.scoreDidUpdate(gameScore)
                }
            }
        }

        // Remove collected rewards and absorbed obstacles
        for object in objectsToRemove {
            gameObjects.removeAll { $0 === object }
            delegate?.didRemoveObject(object)
        }
    }

    private func checkGameOver() {
        if spaceshipState.position.y >= screenBounds.height - spaceshipState.size.height/2 {
            if !isInvulnerable {
                useLife()
            }
        }
    }

    private func gameOver() {
        gameState = .gameOver
        delegate?.gameDidEnd(with: gameScore)
    }

    // MARK: - Static Helper Methods
    static func calculateSpaceshipSize(imageName: String, maxSize: CGFloat) -> CGSize {
        guard let image = UIImage(named: imageName) else {
            return CGSize(width: 100, height: 100)
        }

        let originalSize = image.size
        var newSize = originalSize

        if originalSize.width > maxSize || originalSize.height > maxSize {
            let aspectRatio = originalSize.width / originalSize.height

            if originalSize.width > originalSize.height {
                newSize.width = maxSize
                newSize.height = maxSize / aspectRatio
            } else {
                newSize.height = maxSize
                newSize.width = maxSize * aspectRatio
            }
        }

        return newSize
    }
}
