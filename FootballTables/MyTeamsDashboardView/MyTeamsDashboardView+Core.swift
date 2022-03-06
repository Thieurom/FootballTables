//
//  MyTeamsDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import ComposableArchitecture
import FootballDataClient

struct MyTeamsDashboardView {
    struct State: Equatable {
        // TODO
    }

    enum Action: Equatable {
        case viewDidLoad
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer: Reducer<State, Action, Environment> = .init { state, action, environment in
        switch action {
        case .viewDidLoad:
            return .none
        }
    }
}
