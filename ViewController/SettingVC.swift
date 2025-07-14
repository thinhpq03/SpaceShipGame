//
//  SettingVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 3/7/25.
//

import UIKit

class SettingVC: BaseVC {

    @IBOutlet var lbs: [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        lbs.forEach {
            $0.font = UIFont.Geo(24)
        }
    }
    
    @IBAction func privacy(_ sender: Any) {
    }
    
    @IBAction func rate(_ sender: Any) {
    }
    
    @IBAction func share(_ sender: Any) {
    }
    
    @IBAction func term(_ sender: Any) {
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
