//
//  CompetitionMatchView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import ComposableArchitecture
import FootballDataClient

struct CompetitionMatchView {
    struct State: Equatable {
        let competition: Competition
        var matches: [Match] = []
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

            return environment.apiClient
                .fetchMatches(competitionId: state.competition.id)
                .receive(on: environment.mainQueue)
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
