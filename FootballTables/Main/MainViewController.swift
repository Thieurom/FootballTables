//
//  MainViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import Combine
import ComposableArchitecture
import UIKit

class MainViewController: UITabBarController {
    private let store: Store<AppState, AppAction>
    private let viewStore: ViewStore<AppState, AppAction>
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildViewControllers()

        viewStore.send(.viewDidLoad)
    }
}

extension MainViewController {
    private func setupChildViewControllers() {
        let matchDashboardViewController = MatchDashboardViewController(
            store: store.scope(
                state: \AppState.matchDashboard,
                action: AppAction.matchDashboardAction
            )
        )

        let standingDashboardViewController = StandingDashboardViewController(
            store: store.scope(
                state: \AppState.standingDashboard,
                action: AppAction.standingDashboardAction
            )
        )

        let myTeamsDashboardViewController = MyTeamsDashboardViewController(
            store: store.scope(
                state: \AppState.myTeamsDashboard,
                action: AppAction.myTeamsDashboardAction
            )
        )

        let childViewControllers = [
            matchDashboardViewController,
            standingDashboardViewController,
            myTeamsDashboardViewController
        ]

        let tabBarItems: [UITabBarItem] = [
            .init(title: "Matches", image: UIImage(systemName: "square"), selectedImage: nil),
            .init(title: "Standings", image: UIImage(systemName: "triangle"), selectedImage: nil),
            .init(title: "My Teams", image: UIImage(systemName: "seal"), selectedImage: nil)
        ]

        zip(childViewControllers, tabBarItems).forEach {
            $0.tabBarItem = $1
        }

        viewControllers = childViewControllers.map(UINavigationController.init(rootViewController:))
    }
}
