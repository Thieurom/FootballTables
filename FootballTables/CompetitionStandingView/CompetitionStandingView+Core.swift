//
//  CompetitionStandingView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import FootballDataClient
import IdentifiedCollections

struct CompetitionStandingView {
    struct State: Equatable {
        let competionStanding: CompetitionStanding
        var selectedTeam: TeamView.State?

        var standings: IdentifiedArrayOf<TeamStandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: competionStanding.table.sorted(by: \.position).map(TeamStandingViewState.init(standing:))
                )
            }

            set {}
        }
    }

    enum Action: Equatable {
        case standingAction(id: TeamStandingViewState.ID, action: TeamStandingViewCell.Action)
        case selectTeam(ShortTeam?)
        case teamAction(TeamView.Action)
    }

    struct Environment {}

    static let reducer: Reducer<State, Action, Environment> = .combine(
        TeamStandingViewCell.reducer
            .forEach(
                state: \.standings,
                action: /Action.standingAction,
                environment: { _ in TeamStandingViewCell.Environment() }
            ),

        TeamView.reducer
            .optional()
            .pullback(
                state: \.selectedTeam,
                action: /Action.teamAction,
                environment: { _ in
                    TeamView.Environment()
                }
            ),

        .init { state, action, environment in
            struct CompetionRequestId: Hashable {}

            switch action {
            case .standingAction(let id, action: .selected):
                guard let standing = state.competionStanding.table.first(where: { $0.team.id == id }) else {
                    return .none
                }

                return Effect(value: .selectTeam(standing.team))

            case .selectTeam(let team):
                if let team = team {
                    state.selectedTeam = TeamView.State(team: team)
                } else {
                    state.selectedTeam = nil
                }
                return .none

            case .teamAction:
                return .none
            }
        }
    )
}
