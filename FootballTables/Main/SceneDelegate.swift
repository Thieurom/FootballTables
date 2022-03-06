//
//  SceneDelegate.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import FootballDataClient
import ComposableArchitecture
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let competitionIds = [2021, 2014, 2019, 2002, 2015]

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let tabBarController = UITabBarController()

        tabBarController.viewControllers = [
            matchDashboardViewController(),
            standingDashboardViewController()
        ].map(UINavigationController.init(rootViewController:))

        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

// MARK: - Private

extension SceneDelegate {
    private func matchDashboardViewController() -> MatchDashboardViewController {
        let store = Store(
            initialState: MatchDashboardView.State(
                competitionIds: competitionIds
            ),
            reducer: MatchDashboardView.reducer,
            environment: MatchDashboardView.Environment(
                apiClient: FootballDataClient(apiToken: apiToken),
                mainQueue: .main
            )
        )

        let matchDashboardViewController = MatchDashboardViewController(store: store)
        let tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(systemName: "square")
        tabBarItem.title = "Matches"
        matchDashboardViewController.tabBarItem = tabBarItem

        return matchDashboardViewController
    }

    private func standingDashboardViewController() -> StandingDashboardViewController {
        let store = Store(
            initialState: StandingDashboardView.State(
                competitionIds: competitionIds
            ),
            reducer: StandingDashboardView.reducer,
            environment: StandingDashboardView.Environment(
                apiClient: FootballDataClient(apiToken: apiToken),
                mainQueue: .main
            )
        )

        let standingDashboardViewController = StandingDashboardViewController(store: store)
        let tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(systemName: "arrowtriangle.up")
        tabBarItem.title = "Standings"
        standingDashboardViewController.tabBarItem = tabBarItem

        return standingDashboardViewController
    }
}
