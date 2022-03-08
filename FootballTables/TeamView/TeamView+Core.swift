//
//  TeamView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import FootballDataClient

struct TeamView {
    struct State: Equatable {
        let competition: Competition
        let teamStanding: TeamStanding
        var matches = [Match]()
        var error: AppError? = nil
        var isRequestInFlight: Bool = false
    }

    enum Action: Equatable {
        case fetchMatches
        case matchesResponse(Result<[Match], ApiError>)

        // Child actions
        case matchAction(id: MatchViewState.ID, action: MatchViewCell.Action)
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        struct CancelId: Hashable {}

        switch action {
        case .fetchMatches:
            state.isRequestInFlight = true
            let teamId = state.teamStanding.team.id
            let competition = state.competition

            return environment.apiClient
                .fetchMatches(teamId: teamId)
                .receive(on: environment.mainQueue)
                .map { $0.filter { $0.competition.id == competition.id } }
                .catchToEffect(Action.matchesResponse)
                .cancellable(id: CancelId(), cancelInFlight: true)

        case .matchesResponse(.success(let matches)):
            state.isRequestInFlight = false
            state.matches = matches
            state.error = nil
            return .none

        case .matchesResponse(.failure):
            state.isRequestInFlight = false
            state.matches = []
            state.error = AppError(message: "There's a problem fetching data!")
            return .none

        case .matchAction:
            return .none
        }
    }
}
