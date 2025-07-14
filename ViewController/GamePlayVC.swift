//
//  GamePlayVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 7/7/25.
//

import UIKit

class GamePlayVC: BaseVC {

    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var starCount: UILabel!
    @IBOutlet weak var diamondCount: UILabel!
    @IBOutlet weak var obstacleCount: UILabel!
    @IBOutlet weak var obstacleImage: UIImageView!

    @IBOutlet weak var speedCount: UILabel!
    @IBOutlet weak var shieldCount: UILabel!
    @IBOutlet weak var magnetCount: UILabel!
    @IBOutlet weak var lifeCount: UILabel!

    @IBOutlet var bigLb: [UILabel]!
    @IBOutlet var smallLb: [UILabel]!
    @IBOutlet weak var buttonStk: UIStackView!

    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var gameOverView: UIView!
    
    private var obstaclesByMap: ObstaclesByMap = [:]
    var mapPlay: MapPlay = .map_1
    var mapId: Int!

    // MARK: - Game Components
    private var gameViewModel: GameViewModel!
    private let spaceship = UIImageView()
    private var displayLink: CADisplayLink!

    // MARK: - Power-up UI
    private var speedPowerUpTimer: Timer?
    private var magnetPowerUpTimer: Timer?
    private var speedEffectView: UIView?
    private var shieldEffectView: UIView?
    private var magnetEffectView: UIView?

    // MARK: - Life System UI
    private var invulnerabilityTimer: Timer?
    private var blinkTimer: Timer?
    private var isSpaceshipVisible = true

    // MARK: - Score tracking to prevent duplicate rewards
    private var lastRewardedObstacleCount: Int = 0

    // MARK: - Pause System
    private var wasGameRunning = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMap()
        setUpGame()
        setupView()
        bringButtonsToFront()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Auto-pause if game is running when view disappears
        if gameViewModel.getGameState() == .playing {
            pauseGame()
        }
    }

    // MARK: - Setup Methods

    func setupView() {
        bigLb.forEach { $0.font = UIFont.Geo(32)}
        smallLb.forEach { $0.font = UIFont.Geo(18)}
        obstacleImage.image = UIImage(named: "ingame_" + String(mapId))

        let saved = ScoreStorage.shared.loadScore()
        starCount.text     = "\(saved.starCount)"
        diamondCount.text  = "\(saved.diamondCount)"
        lifeCount.text     = "\(saved.lifeCount)"
        shieldCount.text   = "\(saved.shieldCount)"
        magnetCount.text   = "\(saved.magnetCount)"
        speedCount.text    = "\(saved.speedCount)"

        obstaclesByMap = ScoreStorage.shared.loadObstacles()
        let obs = obstaclesByMap[mapId] ?? 0
        obstacleCount.text = "\(obs)"

        lastRewardedObstacleCount = obs
        pauseView.isHidden = true
        gameOverView.isHidden = true
    }

    // MARK: - UI Layer Management
    private func bringButtonsToFront() {
        view.bringSubviewToFront(buttonStk)
        bigLb.forEach { view.bringSubviewToFront($0) }
        smallLb.forEach { view.bringSubviewToFront($0) }
        view.bringSubviewToFront(pauseView)
    }

    private func setupGameViewModel() {
        gameViewModel = GameViewModel(
            screenBounds: view.bounds,
            mapId: mapId
        )
        gameViewModel.delegate = self
    }

    func setUpMap() {
        guard let mapId = mapId else { return }
        switch mapId {
            case 1:
                mapPlay = .map_1
                backgroundImage.image = UIImage(named: "map_bg_1")
            case 2:
                mapPlay = .map_2
                backgroundImage.image = UIImage(named: "map_bg_2")
            case 3:
                mapPlay = .map_3
                backgroundImage.image = UIImage(named: "map_bg_3")
            case 4:
                mapPlay = .map_4
                backgroundImage.image = UIImage(named: "map_bg_4")
            default:
                break
        }
    }

    private func setUpGame() {
        setupSpaceship()
        setupGameLoop()
    }

    private func setupSpaceship() {
        spaceship.image = UIImage(named: gameViewModel.getSelectedSpaceshipImageName())
        spaceship.frame.size = gameViewModel.getSpaceshipSize()
        spaceship.contentMode = .scaleToFill
        view.addSubview(spaceship)
        spaceship.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)

        view.sendSubviewToBack(spaceship)
        view.sendSubviewToBack(backgroundImage)
    }

    private func setupGameLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink.add(to: .main, forMode: .default)
        displayLink.isPaused = true
    }

    // MARK: - Game Loop
    @objc private func gameLoop(link: CADisplayLink) {
        gameViewModel.update(timestamp: link.timestamp)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Only handle touches if game is in valid state
        let gameState = gameViewModel.getGameState()
        if gameState == .waiting {
            gameViewModel.startGame()
        }

        if gameState == .playing {
            gameViewModel.jump()
        }
    }

    // MARK: - Pause/Resume System
    private func pauseGame() {
        wasGameRunning = (gameViewModel.getGameState() == .playing)
        if wasGameRunning {
            gameViewModel.pauseGame()
            displayLink.isPaused = true
        }
    }

    private func resumeGame() {
        if wasGameRunning {
            gameViewModel.resumeGame()
            displayLink.isPaused = false
        }
    }

    // MARK: - Life System Visual Effects
    private func startInvulnerabilityEffect() {
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.toggleSpaceshipVisibility()
        }

        invulnerabilityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.stopInvulnerabilityEffect()
        }
    }

    private func stopInvulnerabilityEffect() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        invulnerabilityTimer?.invalidate()
        invulnerabilityTimer = nil

        spaceship.alpha = 1.0
        isSpaceshipVisible = true
    }

    private func toggleSpaceshipVisibility() {
        isSpaceshipVisible.toggle()
        UIView.animate(withDuration: 0.05) {
            self.spaceship.alpha = self.isSpaceshipVisible ? 1.0 : 0.3
        }
    }

    // MARK: - Power-up Visual Effects
    private func showSpeedEffect() {
        speedEffectView?.removeFromSuperview()

        speedEffectView = UIView(frame: view.bounds)
        speedEffectView?.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        speedEffectView?.isUserInteractionEnabled = false
        view.addSubview(speedEffectView!)

        view.sendSubviewToBack(speedEffectView!)
        view.sendSubviewToBack(spaceship)
        view.sendSubviewToBack(backgroundImage)

        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.speedEffectView?.alpha = 0.5
        }, completion: nil)
    }

    private func hideSpeedEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.speedEffectView?.alpha = 0
        }) { _ in
            self.speedEffectView?.removeFromSuperview()
            self.speedEffectView = nil
        }
    }

    private func showShieldEffect() {
        shieldEffectView?.removeFromSuperview()

        let shieldSize = CGSize(width: spaceship.frame.width + 20, height: spaceship.frame.height + 20)
        shieldEffectView = UIView(frame: CGRect(origin: .zero, size: shieldSize))
        shieldEffectView?.backgroundColor = UIColor.clear
        shieldEffectView?.layer.borderColor = UIColor.systemYellow.cgColor
        shieldEffectView?.layer.borderWidth = 3
        shieldEffectView?.layer.cornerRadius = min(shieldSize.width, shieldSize.height) / 2
        shieldEffectView?.isUserInteractionEnabled = false
        view.addSubview(shieldEffectView!)

        view.sendSubviewToBack(shieldEffectView!)
        view.sendSubviewToBack(spaceship)
        view.sendSubviewToBack(backgroundImage)

        updateShieldPosition()

        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.shieldEffectView?.alpha = 0.7
        }, completion: nil)
    }

    private func hideShieldEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.shieldEffectView?.alpha = 0
        }) { _ in
            self.shieldEffectView?.removeFromSuperview()
            self.shieldEffectView = nil
        }
    }

    private func updateShieldPosition() {
        guard let shieldView = shieldEffectView else { return }
        shieldView.center = spaceship.center
    }

    private func showMagnetEffect() {
        magnetEffectView?.removeFromSuperview()

        let magnetSize = CGSize(width: 300, height: 300)
        magnetEffectView = UIView(frame: CGRect(origin: .zero, size: magnetSize))
        magnetEffectView?.backgroundColor = UIColor.purple.withAlphaComponent(0.1)
        magnetEffectView?.layer.borderColor = UIColor.purple.cgColor
        magnetEffectView?.layer.borderWidth = 2
        magnetEffectView?.layer.cornerRadius = magnetSize.width / 2
        magnetEffectView?.isUserInteractionEnabled = false
        view.addSubview(magnetEffectView!)

        view.sendSubviewToBack(magnetEffectView!)
        view.sendSubviewToBack(spaceship)
        view.sendSubviewToBack(backgroundImage)

        updateMagnetPosition()

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2.0
        rotationAnimation.repeatCount = .infinity
        magnetEffectView?.layer.add(rotationAnimation, forKey: "rotation")
    }

    private func hideMagnetEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.magnetEffectView?.alpha = 0
        }) { _ in
            self.magnetEffectView?.removeFromSuperview()
            self.magnetEffectView = nil
        }
    }

    private func updateMagnetPosition() {
        guard let magnetView = magnetEffectView else { return }
        magnetView.center = spaceship.center
    }

    // MARK: - Actions
    @IBAction func speedClick(_ sender: UIButton) {
        print("Speed button clicked")

        let saved = ScoreStorage.shared.loadScore()
        guard saved.speedCount > 0 else {
            showMessage("You don't have any speed power-ups left.")
            return
        }

        if gameViewModel.activateSpeedPowerUp() {
            var updatedScore = saved
            updatedScore.speedCount -= 1
            ScoreStorage.shared.save(updatedScore)
            speedCount.text = "\(updatedScore.speedCount)"
            showMessage("Speed power-up activated! Your spaceship will move faster.")
        } else {
            showMessage("Speed power-up is already active or game is not running.")
        }
    }

    @IBAction func shieldClick(_ sender: UIButton) {
        print("Shield button clicked")

        let saved = ScoreStorage.shared.loadScore()
        guard saved.shieldCount > 0 else {
            showMessage("You don't have any shields left.\nCollect more shields to activate them.")
            return
        }

        if gameViewModel.activateShieldPowerUp() {
            var updatedScore = saved
            updatedScore.shieldCount -= 1
            ScoreStorage.shared.save(updatedScore)
            shieldCount.text = "\(updatedScore.shieldCount)"
            showMessage("Shield activated!")
        } else {
            showMessage("Shield is already active or game is not running.")
        }
    }

    @IBAction func magnetClick(_ sender: UIButton) {
        print("Magnet button clicked")

        let saved = ScoreStorage.shared.loadScore()
        guard saved.magnetCount > 0 else {
            showMessage("You don't have any magnet power-ups left.")
            return
        }

        if gameViewModel.activateMagnetPowerUp() {
            var updatedScore = saved
            updatedScore.magnetCount -= 1
            ScoreStorage.shared.save(updatedScore)
            magnetCount.text = "\(updatedScore.magnetCount)"
            showMessage("Magnet activated!")
        } else {
            showMessage("Magnet is already active or game is not running.")
        }
    }

    @IBAction func pauseClick(_ sender: Any) {
        pauseGame()
        pauseView.isHidden = false
    }

    @IBAction func resume(_ sender: Any) {
        resumeGame()
        pauseView.isHidden = true
    }

    @IBAction func retry(_ sender: Any) {
        restartGame()
        pauseView.isHidden = true
        gameOverView.isHidden = true
    }

    @IBAction func back(_ sender: Any) {
        if gameViewModel.getGameState() == .playing {
            pauseGame()
        }
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Game Management
    private func restartGame() {
        gameViewModel.restartGame()
        spaceship.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        displayLink.isPaused = true
        wasGameRunning = false

        let obstaclesByMap = ScoreStorage.shared.loadObstacles()
        lastRewardedObstacleCount = obstaclesByMap[mapId] ?? 0

        cleanupEffects()
        bringButtonsToFront()
    }

    private func cleanupEffects() {
        hideSpeedEffect()
        hideShieldEffect()
        hideMagnetEffect()
        stopInvulnerabilityEffect()

        speedPowerUpTimer?.invalidate()
        magnetPowerUpTimer?.invalidate()
        speedPowerUpTimer = nil
        magnetPowerUpTimer = nil
    }

    // MARK: - Deinitialization
    deinit {
        displayLink?.invalidate()
        cleanupEffects()
    }
}

// MARK: - GameViewModelDelegate
extension GamePlayVC: GameViewModelDelegate {
    func gameDidStart() {
        displayLink.isPaused = false
        wasGameRunning = true
        bringButtonsToFront()
    }

    func gameDidEnd(with score: GameScore) {
        displayLink.isPaused = true
        wasGameRunning = false

        var saved = ScoreStorage.shared.loadScore()
        var obstaclesByMap = ScoreStorage.shared.loadObstacles()

        saved.starCount += score.starCount
        saved.diamondCount += score.diamondCount

        let currentObstacles = obstaclesByMap[mapId] ?? 0
        let finalObstacles = currentObstacles + score.obstaclesPassed
        obstaclesByMap[mapId] = finalObstacles

        ScoreStorage.shared.save(saved)
        ScoreStorage.shared.saveObstacles(obstaclesByMap)

        starCount.text = "\(saved.starCount)"
        diamondCount.text = "\(saved.diamondCount)"
        obstacleCount.text = "\(finalObstacles)"

        cleanupEffects()
        showGameOverAlert(with: score)
    }

    func gameDidPause() {
        displayLink.isPaused = true
        print("Game paused")
    }

    func gameDidResume() {
        displayLink.isPaused = false
        print("Game resumed")
    }

    func spaceshipDidMove(to position: CGPoint) {
        spaceship.center = position
        updateShieldPosition()
        updateMagnetPosition()
    }

    func didSpawnObject(_ object: GameObject) {
        view.addSubview(object)
        view.sendSubviewToBack(object)
        view.sendSubviewToBack(spaceship)
        view.sendSubviewToBack(backgroundImage)
    }

    func didRemoveObject(_ object: GameObject) {
        object.removeFromSuperview()
    }

    func scoreDidUpdate(_ score: GameScore) {
        var saved = ScoreStorage.shared.loadScore()
        let obstaclesByMap = ScoreStorage.shared.loadObstacles()

        let displayStar = saved.starCount + score.starCount
        let displayDiamond = saved.diamondCount + score.diamondCount
        let currentObstacles = obstaclesByMap[mapId] ?? 0
        let displayObstacle = currentObstacles + score.obstaclesPassed

        if displayObstacle > lastRewardedObstacleCount {
            let (threshold, rewardKeyPath): (Int, WritableKeyPath<SavedScore, Int>) = {
                switch mapId {
                    case 1: return (8, \.lifeCount)
                    case 2: return (8, \.magnetCount)
                    case 3: return (5, \.speedCount)
                    case 4: return (2, \.shieldCount)
                    default: return (Int.max, \.lifeCount)
                }
            }()

            let previousCompleteMilestones = lastRewardedObstacleCount / threshold
            let currentCompleteMilestones = displayObstacle / threshold
            let newMilestones = currentCompleteMilestones - previousCompleteMilestones

            if newMilestones > 0 {
                saved[keyPath: rewardKeyPath] += newMilestones
                ScoreStorage.shared.save(saved)
                print("Awarded \(newMilestones) milestone rewards for reaching \(displayObstacle) obstacles")
            }

            lastRewardedObstacleCount = displayObstacle
        }

        starCount.text = "\(displayStar)"
        diamondCount.text = "\(displayDiamond)"
        obstacleCount.text = "\(displayObstacle)"
        lifeCount.text = "\(saved.lifeCount)"
        shieldCount.text = "\(saved.shieldCount)"
        magnetCount.text = "\(saved.magnetCount)"
        speedCount.text = "\(saved.speedCount)"
    }

    func powerUpDidActivate(_ type: PowerUpType, duration: CFTimeInterval) {
        switch type {
            case .speed:
                showSpeedEffect()
                speedPowerUpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    let remaining = self?.gameViewModel.getSpeedPowerUpTimeRemaining() ?? 0
                    if remaining <= 0 {
                        timer.invalidate()
                        self?.speedPowerUpTimer = nil
                    }
                }

            case .shield:
                showShieldEffect()

            case .magnet:
                showMagnetEffect()
                magnetPowerUpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    let remaining = self?.gameViewModel.getMagnetPowerUpTimeRemaining() ?? 0
                    if remaining <= 0 {
                        timer.invalidate()
                        self?.magnetPowerUpTimer = nil
                    }
                }
        }
    }

    func powerUpDidExpire(_ type: PowerUpType) {
        switch type {
            case .speed:
                hideSpeedEffect()
                speedPowerUpTimer?.invalidate()
                speedPowerUpTimer = nil

            case .shield:
                hideShieldEffect()

            case .magnet:
                hideMagnetEffect()
                magnetPowerUpTimer?.invalidate()
                magnetPowerUpTimer = nil
        }
    }

    func lifeDidDecrease(newCount: Int) {
        lifeCount.text = "\(newCount)"
        updateLifeDisplay(newCount)

        if newCount > 0 {
            showMessage("Life lost! You have \(newCount) lives remaining.")
        }
    }

    func invulnerabilityDidStart() {
        startInvulnerabilityEffect()
    }

    func invulnerabilityDidEnd() {
        stopInvulnerabilityEffect()
    }

    func updateLifeDisplay(_ count: Int) {
        lifeCount.text = "\(count)"

        // Add visual feedback for life changes
        UIView.animate(withDuration: 0.3, animations: {
            self.lifeCount.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.lifeCount.transform = CGAffineTransform.identity
            }
        }
    }

    // MARK: - Private Helper Methods
    private func showGameOverAlert(with score: GameScore) {
        gameOverView.isHidden = false
    }
}
