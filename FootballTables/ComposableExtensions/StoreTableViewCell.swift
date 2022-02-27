//
//  StoreTableViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import Combine
import ComposableArchitecture
import UIKit

public class StoreTableViewCell<State: Equatable, Action>: UITableViewCell {
    public var store: Store<State, Action>? {
        didSet {
            if let store = store {
                viewStore = ViewStore(store)
                observeViewStore()
            } else {
                viewStore = nil
            }
        }
    }

    public private(set) var viewStore: ViewStore<State, Action>?
    public var cancellables = Set<AnyCancellable>()

    public override func prepareForReuse() {
        super.prepareForReuse()

        cancellables.removeAll()
    }

    /// Overwrite this method
    open func observeViewStore() {}
}
