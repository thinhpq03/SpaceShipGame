//
//  HomeVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 3/7/25.
//

import UIKit

class HomeVC: BaseVC {

    @IBOutlet var lbs: [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    func setupView() {
        lbs.forEach {
            $0.font = UIFont.Geo(32)
        }
    }

    @IBAction func quickGame(_ sender: Any) {
        let GamePlayVC: GamePlayVC = UIStoryboard.getVC()
        GamePlayVC.mapId = Int.random(in: 1...4)
        self.navigationController?.pushViewController(GamePlayVC, animated: true)
    }
    
    @IBAction func mission(_ sender: Any) {
        let vc: MissionVC = UIStoryboard.getVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func map(_ sender: Any) {
        let vc: MapVC = UIStoryboard.getVC()
        vc.typeShow = .map
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func spaceship(_ sender: Any) {
    }

    @IBAction func store(_ sender: Any) {
        let vc: StoreVC = UIStoryboard.getVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func space(_ sender: Any) {
        let vc: MapVC = UIStoryboard.getVC()
        vc.typeShow = .knowledge
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func setting(_ sender: Any) {
        let vc: SettingVC = UIStoryboard.getVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
