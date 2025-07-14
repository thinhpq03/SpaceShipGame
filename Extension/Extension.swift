//
//  Extension.swift
//  SpaceShipGame
//
//  Created by Phạm Quý Thịnh on 3/7/25.
//

import Foundation
import UIKit

// MARK: - UIStoryboard Extension
public extension UIStoryboard {
    /// Returns view controller instance from storyboard by type and optional storyboard name
    static func instantiate<T: UIViewController>(_: T.Type, storyboard name: String = "Main") -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("ViewController with identifier \(String(describing: T.self)) not found in \(name) storyboard.")
        }
        return vc
    }

    /// Shorthand to instantiate a view controller without specifying type explicitly
    static func getVC<T: UIViewController>(storyboard name: String = "Main") -> T {
        return instantiate(T.self, storyboard: name)
    }
}

// MARK: - UITableView & UICollectionView Cell Registration & Dequeue
public extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
    func dequeue<T: UITableViewCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
}

public extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    func dequeue<T: UICollectionViewCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue collection cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
}

// MARK: - UIViewController Message Overlay
public extension UIViewController {
    /// Shows a temporary overlay message at top of the view controller
    func showMessage(_ text: String, duration: TimeInterval = 2.0) {
        let label = PaddingLabel()
        label.text = text
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        // Pin to top safe area
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: guide.widthAnchor, multiplier: 0.9)
        ])

        label.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}

// Custom UILabel with padding
public class PaddingLabel: UILabel {
    public var inset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }
}

// MARK: - UIColor Hex Support
public extension UIColor {
    /// Initialize with hex string, supports #RRGGBB or RRGGBB
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6, let intCode = Int(hexString, radix: 16) else {
            self.init(white: 0.0, alpha: 0.0)
            return
        }
        let red = CGFloat((intCode >> 16) & 0xFF) / 255.0
        let green = CGFloat((intCode >> 8) & 0xFF) / 255.0
        let blue = CGFloat(intCode & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - UIFont Extension for Dynamic Sizing
public extension UIFont {
    /// Returns a font scaled up by ipadScale on iPad devices
    static func Geo(_ size: CGFloat) -> UIFont? {
        let size = iPhone ? size : size + 6
        return UIFont(name: "Geo-Regular", size: size)
    }
}

extension UIColor {
    static let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
}
