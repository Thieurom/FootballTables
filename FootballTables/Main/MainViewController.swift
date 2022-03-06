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
    let store: Store<AppState, AppAction>
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, AppAction>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildViewControllers()
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
            .init(title: "Standings", image: UIImage(systemName: "arrowtriangle.up"), selectedImage: nil),
            .init(title: "My Teams", image: UIImage(systemName: "seal"), selectedImage: nil)
        ]

        zip(childViewControllers, tabBarItems).forEach {
            $0.tabBarItem = $1
        }

        viewControllers = childViewControllers.map(UINavigationController.init(rootViewController:))
    }
}
