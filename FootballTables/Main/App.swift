//
//  App.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import ComposableArchitecture
import FootballDataClient

struct AppState: Equatable {
    let competitionIds: [Int]
    var followingTeams = [CompetitionTeam]()

    // Child states
    var _matchDashboard: MatchDashboardView.State?
    var matchDashboard: MatchDashboardView.State {
        get {
            _matchDashboard ?? .init(competitionIds: competitionIds)
        }
        
        set {
            _matchDashboard = newValue
        }
    }

    var _standingDashboard: StandingDashboardView.State?
    var standingDashboard: StandingDashboardView.State {
        get {
            if _standingDashboard == nil {
                return .init(
                    competitionIds: competitionIds,
                    followingTeams: followingTeams
                )
            }

            var copy = _standingDashboard!
            copy.followingTeams = followingTeams
            return copy
        }

        set {
            followingTeams = newValue.followingTeams
            _standingDashboard = newValue
        }
    }

    var _myTeamsDashboard: MyTeamsDashboardView.State?
    var myTeamsDashboard: MyTeamsDashboardView.State {
        get {
            if _myTeamsDashboard == nil {
                return  .init(followingTeams: followingTeams)
            }

            var copy = _myTeamsDashboard!
            copy.followingTeams = followingTeams
            return copy
        }

        set {
            followingTeams = newValue.followingTeams
            _myTeamsDashboard = newValue
        }
    }
}

struct AppViewState: StoreViewState {
    init(state: AppState) {}
}

enum AppAction: Equatable {
    case viewDidLoad

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
        case .viewDidLoad:
            // TODO: Load following team ids from persistent storage!
            state.followingTeams = []
            return .none

        case .matchDashboardAction:
            return .none

        case .standingDashboardAction:
            return .none

        case .myTeamsDashboardAction:
            return .none
        }
    }
)
