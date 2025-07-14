//
//  MissionVC.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 9/7/25.
//

import UIKit

class MissionVC: BaseVC {

    private let padding: CGFloat = iPhone ? 20 : 30
    private let spacing: CGFloat = iPhone ? 45 : 60

    @IBOutlet weak var missionClv: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        missionClv.register(cellType: MissionCell.self)
        missionClv.delegate = self
        missionClv.dataSource = self
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension MissionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MissionCell = collectionView.dequeue(cellType: MissionCell.self, for: indexPath)
        cell.configure(index: indexPath.item + 1)
        return cell
    }

}

extension MissionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width - padding * 2
        let height: CGFloat = width /  360 * 215
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
