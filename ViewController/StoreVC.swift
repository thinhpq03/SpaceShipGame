//
//  StoreVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 10/7/25.
//

import UIKit

class StoreVC: BaseVC {

    private let padding: CGFloat = iPhone ? 15 : 25
    private let spacing: CGFloat = iPhone ? 35 : 50

    @IBOutlet weak var storeClv: UICollectionView!
    @IBOutlet weak var starCount: UILabel!
    @IBOutlet weak var diamondCount: UILabel!

    private let spaceshipCosts = [50, 70, 90]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupClv()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    func setupView() {
        let saved = ScoreStorage.shared.loadScore()
        starCount.font = UIFont.Geo(32)
        diamondCount.font = UIFont.Geo(32)
        starCount.text = "\(saved.starCount)"
        diamondCount.text = "\(saved.diamondCount)"
    }

    func setupClv() {
        storeClv.register(cellType: StoreCell.self)
        storeClv.delegate = self
        storeClv.dataSource = self
    }

    private func purchaseSpaceship(at index: Int) {
        let spaceshipNumber = index + 1
        let saved = ScoreStorage.shared.loadScore()

        let costIndex = index / 2
        let cost = spaceshipCosts[costIndex]

        var canPurchase = false
        var newScore = saved

        if index < 3 {
            if saved.starCount >= cost {
                newScore.starCount -= cost
                canPurchase = true
            }
        } else {
            if saved.diamondCount >= cost {
                newScore.diamondCount -= cost
                canPurchase = true
            }
        }

        if canPurchase {
            SpaceshipManager.shared.unlockSpaceship(spaceshipNumber)
            ScoreStorage.shared.save(newScore)
            setupView()
            storeClv.reloadData()

            showPurchaseAlert(success: true, spaceshipNumber: spaceshipNumber)
        } else {
            showPurchaseAlert(success: false, spaceshipNumber: spaceshipNumber)
        }
    }

    private func showPurchaseAlert(success: Bool, spaceshipNumber: Int) {
        let alert = UIAlertController(
            title: success ? "Success!" : "Not enough money!",
            message: success ? "You bought this spaceship" : "You don't have enough credits to buy this spaceship",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Public Methods
    func getSelectedSpaceshipImageName() -> String {
        return SpaceshipManager.shared.selectedSpaceshipImageName
    }

    private func selectSpaceship(_ spaceshipNumber: Int) {
        guard SpaceshipManager.shared.selectSpaceship(spaceshipNumber) else { return }
        storeClv.reloadData() // Reload to update button states
    }
}

extension StoreVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cellType: StoreCell.self, for: indexPath)

        let spaceshipNumber = indexPath.item + 1
        let costIndex = indexPath.item / 2
        let cost = spaceshipCosts[costIndex]
        let isUnlocked = SpaceshipManager.shared.isSpaceshipUnlocked(spaceshipNumber)
        let isSelected = SpaceshipManager.shared.selectedSpaceship == spaceshipNumber
        let currencyType = indexPath.item < 3 ? "star" : "diamond"

        cell.configure(
            spaceshipNumber: spaceshipNumber,
            cost: cost,
            isUnlocked: isUnlocked,
            isSelected: isSelected,
            currencyType: currencyType
        )

        // Set up selection callback
        cell.onSelectTapped = { [weak self] in
            self?.selectSpaceship(spaceshipNumber)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let spaceshipNumber = indexPath.item + 1

        if !SpaceshipManager.shared.isSpaceshipUnlocked(spaceshipNumber) {
            purchaseSpaceship(at: indexPath.item)
        } else {
            // If already unlocked, select it
            selectSpaceship(spaceshipNumber)
        }
    }
}

extension StoreVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - padding * 2 - spacing) / 2
        let height: CGFloat = width * 230 / 160
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
}
