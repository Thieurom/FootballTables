//
//  RoundedButtonStyle.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 08/03/2022.
//

import UIKit

extension UIButton {
    static func roundedButtonStyle(_ button: UIButton) {
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 16
    }
}
