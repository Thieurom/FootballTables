//
//  App.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import ComposableArchitecture
import ComposableExtensions
import FootballDataClient
import MatchDashboardView
import Models
import MyTeamsDashboardView
import StandingDashboardView

public struct AppState: Equatable {
    public let competitionIds: [Int]
    public var followingTeams: [CompetitionTeam]

    public init(competitionIds: [Int]) {
        self.competitionIds = competitionIds
        self.followingTeams = []
        self._matchDashboard = nil
        self._standingDashboard = nil
        self._myTeamsDashboard = nil
    }

    // Child states
    var _matchDashboard: MatchDashboardView.State?
    public var matchDashboard: MatchDashboardView.State {
        get {
            _matchDashboard ?? .init(competitionIds: competitionIds)
        }
        
        set {
            _matchDashboard = newValue
        }
    }

    var _standingDashboard: StandingDashboardView.State?
    public var standingDashboard: StandingDashboardView.State {
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
    public var myTeamsDashboard: MyTeamsDashboardView.State {
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

public struct AppViewState: StoreViewState {
    public init(state: AppState) {}
}

public enum AppAction: Equatable {
    case viewDidLoad

    // Child actions
    case matchDashboardAction(MatchDashboardView.Action)
    case standingDashboardAction(StandingDashboardView.Action)
    case myTeamsDashboardAction(MyTeamsDashboardView.Action)
}

public struct AppEnvironment {
    public var apiClient: FootballDataClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(apiClient: FootballDataClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.apiClient = apiClient
        self.mainQueue = mainQueue
    }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
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
