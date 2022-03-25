//
//  Array+Extensions.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import Foundation

extension Array {
    public func removeAllDuplicates(by comparator: @escaping (Element, Element) -> Bool) -> Array<Element> {
        return reduce([Element]()) { uniques, current in
            if uniques.contains(where: { comparator($0, current) }) {
                return uniques
            }

            return uniques + [current]
        }
    }
}

extension Array where Element: Equatable {
    public func removeAllDuplicates() -> Array<Element> {
        return removeAllDuplicates(by: ==)
    }
}
