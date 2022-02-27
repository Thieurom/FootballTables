//
//  TeamView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import FootballDataClient
import ComposableArchitecture

struct TeamView {
    struct State: Equatable {
        let team: ShortTeam
    }

    enum Action: Equatable {
        case viewDidLoad
    }

    struct Environment {}

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .viewDidLoad:
            return .none
        }
    }
}
