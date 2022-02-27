//
//  UITableViewDiffableDataSource+Extensions.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import UIKit

extension UITableViewDiffableDataSource {
    var snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        get { snapshot() }
        set { apply(newValue, animatingDifferences: true) }
    }

    var snapshotWithoutAnimation: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        get { snapshot() }
        set { apply(newValue, animatingDifferences: false) }
    }
}
