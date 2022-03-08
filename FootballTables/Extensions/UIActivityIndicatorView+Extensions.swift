//
//  UIActivityIndicatorView+Extensions.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 07/03/2022.
//

import UIKit

extension UIActivityIndicatorView {
    var _isAnimating: Bool {
        get { isAnimating }

        set {
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
}
