//
//  App.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import ComposableArchitecture
import FootballDataClient

struct AppState: Equatable {

    // Child states
    var matchDashboard: MatchDashboardView.State
    var standingDashboard: StandingDashboardView.State
    var myTeamsDashboard: MyTeamsDashboardView.State
}

struct AppViewState: StoreViewState {
    init(state: AppState) {}
}

enum AppAction: Equatable {
    // Child actions
    case matchDashboardAction(MatchDashboardView.Action)
    case standingDashboardAction(StandingDashboardView.Action)
    case myTeamsDashboardAction(MyTeamsDashboardView.Action)
}

struct AppEnvironment {
    var apiClient: FootballDataClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    MatchDashboardView.reducer
        .pullback(
            state: \.matchDashboard,
            action: /AppAction.matchDashboardAction,
            environment: {
                MatchDashboardView.Environment(
                    apiClient: $0.apiClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),

    StandingDashboardView.reducer
        .pullback(
            state: \.standingDashboard,
            action: /AppAction.standingDashboardAction,
            environment: {
                StandingDashboardView.Environment(
                    apiClient: $0.apiClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),

    MyTeamsDashboardView.reducer
        .pullback(
            state: \.myTeamsDashboard,
            action: /AppAction.myTeamsDashboardAction,
            environment: {
                MyTeamsDashboardView.Environment(
                    apiClient: $0.apiClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),

    Reducer { state, action, environment in
        switch action {
        case .matchDashboardAction:
            return .none
        case .standingDashboardAction:
            return .none
        case .myTeamsDashboardAction:
            return .none
        }
    }
)
