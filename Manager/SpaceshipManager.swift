//
//  SpaceshipManager.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 10/7/25.
//

import Foundation

class SpaceshipManager {
    static let shared = SpaceshipManager()
    
    private let selectedSpaceshipKey = "selectedSpaceship"
    private let unlockedSpaceshipsKey = "unlockedSpaceships"
    
    private init() {}
    
    // MARK: - Selected Spaceship
    var selectedSpaceship: Int {
        get {
            let saved = UserDefaults.standard.integer(forKey: selectedSpaceshipKey)
            // If no spaceship is selected, default to spaceship 1
            return saved == 0 ? 1 : saved
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedSpaceshipKey)
        }
    }
    
    var selectedSpaceshipImageName: String {
        return "spaceship_\(selectedSpaceship)"
    }
    
    // MARK: - Unlocked Spaceships
    var unlockedSpaceships: Set<Int> {
        get {
            let saved = UserDefaults.standard.array(forKey: unlockedSpaceshipsKey) as? [Int] ?? [1]
            return Set(saved)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: unlockedSpaceshipsKey)
        }
    }
    
    // MARK: - Helper Methods
    func isSpaceshipUnlocked(_ spaceshipNumber: Int) -> Bool {
        return unlockedSpaceships.contains(spaceshipNumber)
    }
    
    func unlockSpaceship(_ spaceshipNumber: Int) {
        var unlocked = unlockedSpaceships
        unlocked.insert(spaceshipNumber)
        unlockedSpaceships = unlocked
    }
    
    func selectSpaceship(_ spaceshipNumber: Int) -> Bool {
        guard isSpaceshipUnlocked(spaceshipNumber) else { return false }
        selectedSpaceship = spaceshipNumber
        return true
    }
}
