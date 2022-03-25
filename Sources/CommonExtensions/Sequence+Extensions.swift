//
//  Sequence+Extensions.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import Foundation

extension Sequence {
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
