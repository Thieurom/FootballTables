//
//  UIButton+Styles.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 08/03/2022.
//

import UIKit

extension UIButton {
    static func roundedButtonStyle(_ button: UIButton) {
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.darkGray.cgColor
    }

    static func primaryButtonStyle(_ button: UIButton) {
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
    }

    static func secondaryButtonStyle(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.darkGray, for: .normal)
    }
}
