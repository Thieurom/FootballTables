//
//  Applicable.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import Foundation

public protocol Applicable {}

public extension Applicable {
    @discardableResult
    func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Applicable {}
