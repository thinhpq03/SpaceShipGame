//
//  StoreCell.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 10/7/25.
//

import UIKit

class StoreCell: UICollectionViewCell {

    @IBOutlet weak var spaceShip: UIImageView!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var starDiamond: UIImageView!
    @IBOutlet weak var costView: UIView!
    @IBOutlet weak var selectBtn: UIButton!

    var onSelectTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        cost.font = UIFont.Geo(32)
        selectBtn.titleLabel?.font = UIFont.Geo(32)
        setupSelectButton()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        spaceShip.image = nil
        starDiamond.image = nil
        cost.text = ""
        costView.isHidden = false
        selectBtn.isHidden = false
        spaceShip.alpha = 1.0
        onSelectTapped = nil
    }

    private func setupSelectButton() {
        selectBtn.backgroundColor = UIColor.clear
        selectBtn.setTitleColor(.white, for: .normal)
    }

    func configure(spaceshipNumber: Int, cost: Int, isUnlocked: Bool, isSelected: Bool, currencyType: String) {
        spaceShip.image = UIImage(named: "spaceship_\(spaceshipNumber)")

        starDiamond.image = UIImage(named: currencyType)

        self.cost.text = "\(cost)"

        costView.isHidden = isUnlocked
        selectBtn.isHidden = !isUnlocked
        spaceShip.alpha = isUnlocked ? 1.0 : 0.7

        if isSelected {
            selectBtn.setTitle("SELECTED", for: .normal)
            selectBtn.isUserInteractionEnabled = false
        } else {
            selectBtn.setTitle("SELECT", for: .normal)
            selectBtn.backgroundColor = UIColor.clear
            selectBtn.isUserInteractionEnabled = true
        }
    }

    @IBAction func selectSpaceShip(_ sender: Any) {
        onSelectTapped?()
    }
}
