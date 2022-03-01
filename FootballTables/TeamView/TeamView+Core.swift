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
        let teamStanding: TeamStanding
        let competitionId: Int
        let competitionName: String
        var matches = [Match]()
        var isRequestInFlight: Bool = false
    }

    enum Action: Equatable {
        case viewDidLoad
        case matchesResponse(Result<[Match], ApiError>)
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .viewDidLoad:
            state.isRequestInFlight = true
            let teamId = state.teamStanding.team.id
            let competitionId = state.competitionId

            return environment.apiClient
                .fetchMatches(teamId: teamId)
                .receive(on: environment.mainQueue)
                .map { $0.filter { $0.competitionId == competitionId } }
                .catchToEffect(Action.matchesResponse)

        case .matchesResponse(.success(let matches)):
            state.isRequestInFlight = false
            state.matches = matches
            return .none

        case .matchesResponse(.failure):
            state.isRequestInFlight = false
            state.matches = []
            return .none
        }
    }
}
