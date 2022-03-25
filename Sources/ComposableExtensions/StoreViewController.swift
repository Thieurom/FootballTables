//
//  StoreViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import Combine
import ComposableArchitecture
import UIKit

open class StoreViewController<State, ViewState, Action>: UIViewController where State: Equatable, ViewState: StoreViewState, ViewState.State == State {

    public let store: Store<State, Action>
    public let viewStore: ViewStore<ViewState, Action>
    public var cancellables = Set<AnyCancellable>()

    public init(store: Store<State, Action>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
