//
//  MissionCell.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 9/7/25.
//

import UIKit

class MissionCell: UICollectionViewCell {

    @IBOutlet weak var item: UIImageView!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var ingame: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        des.font = UIFont.Geo(24)
        count.font = UIFont.Geo(30)
    }

    func configure(index: Int) {
        switch index {
            case 1:
                item.image = UIImage(named: "life")
                ingame.image = UIImage(named: "ingame_1")
                count.text = "80"
                des.text = "Avoid 80 islands for 1 life"
            case 2:
                item.image = UIImage(named: "magnet")
                ingame.image = UIImage(named: "ingame_2")
                count.text = "80"
                des.text = "Get 80 islands for 1 magnet"
            case 3:
                item.image = UIImage(named: "speed")
                ingame.image = UIImage(named: "ingame_3")
                count.text = "50"
                des.text = "Avoid 50 islands to get 1 speed boost"
            case 4:
                item.image = UIImage(named: "shield")
                ingame.image = UIImage(named: "ingame_4")
                count.text = "50"
                des.text = "Get 50 islands for 1 protective shield"
            default:
                break
        }
    }

}
