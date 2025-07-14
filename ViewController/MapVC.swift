//
//  MapVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 4/7/25.
//

import UIKit

enum TypeShow {
    case map
    case knowledge
}

class MapVC: BaseVC {

    @IBOutlet weak var mapClv: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!

    private let mapName: [String] = ["map1", "map2", "map3", "map4"]
    private let knowLedge: [String] = ["Space Knowledge", "Space Knowledge-1", "Space Knowledge-2", "Space Knowledge-3", "Space Knowledge-4", "Space Knowledge-5", "Space Knowledge-6", "Space Knowledge-7", "Space Knowledge-8", "Space Knowledge-9"]

    var typeShow: TypeShow = .map

    private var items: [String] {
        switch typeShow {
            case .map:       return mapName
            case .knowledge: return knowLedge
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }

    func setup() {
        mapClv.register(cellType: MapCell.self)
        mapClv.delegate   = self
        mapClv.dataSource = self
        view.bringSubviewToFront(btnBack)
        if typeShow == .knowledge {
            mapClv.isPagingEnabled = true
        } else {
            mapClv.isPagingEnabled = false
        }
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cellType: MapCell.self, for: indexPath)
        let name = items[indexPath.row]
        cell.mapImg.image = UIImage(named: name)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch typeShow {
            case .map:
                let vc: GamePlayVC = UIStoryboard.getVC()
                vc.mapId = indexPath.item + 1
                navigationController?.pushViewController(vc, animated: true)
            case .knowledge:
                return
        }
    }
}

extension MapVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
