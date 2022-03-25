//
//  CompetitionMatchView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import ComposableArchitecture
import FootballDataClient
import Models
import MatchViewCell

public struct CompetitionMatchView {
    public struct State: Equatable {
        public let competition: Competition
        public var matches: [Match] = []
        public var error: AppError? = nil
        public var isRequestInFlight: Bool = false

        public init(competition: Competition, matches: [Match] = [], error: AppError? = nil, isRequestInFlight: Bool = false) {
            self.competition = competition
            self.matches = matches
            self.error = error
            self.isRequestInFlight = isRequestInFlight
        }
    }

    public enum Action: Equatable {
        case fetchMatches
        case matchesResponse(Result<[Match], ApiError>)

        // Child actions
        case matchAction(id: MatchViewState.ID, action: MatchViewCell.Action)
    }

    public struct Environment {
        public var apiClient: FootballDataClient
        public var mainQueue: AnySchedulerOf<DispatchQueue>

        public init(apiClient: FootballDataClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.apiClient = apiClient
            self.mainQueue = mainQueue
        }
    }

    public static let reducer = Reducer<State, Action, Environment> { state, action, environment in
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
