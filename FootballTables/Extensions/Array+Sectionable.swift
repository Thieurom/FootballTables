//
//  Array+Sectionable.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//
import UIKit

extension Array where Element: Sectionable {
    var snapshot: NSDiffableDataSourceSnapshot<Element, Element.Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Element, Element.Item>()

        forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items)
        }

        return snapshot
    }
}
