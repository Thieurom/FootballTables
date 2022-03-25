//
//  CompetitionStandingView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import FootballDataClient
import Models
import TeamView

public struct CompetitionStandingView {
    public struct State: Equatable {
        public let competionStanding: CompetitionStanding
        public var followingTeams: [CompetitionTeam]

        public init(competionStanding: CompetitionStanding, followingTeams: [CompetitionTeam]) {
            self.competionStanding = competionStanding
            self.followingTeams = followingTeams
            self._selectedTeam = nil
        }

        // Child states

        var _selectedTeam: TeamView.State?
        var selectedTeam: TeamView.State? {
            get {
                return _selectedTeam
            }
            set {
                if let teamViewState = newValue, teamViewState != selectedTeam {
                    if teamViewState.team.isFollowing {
                        followingTeams.append(teamViewState.team)
                    } else {
                        followingTeams.removeAll(where: { $0.id == teamViewState.team.id })
                    }
                }
                _selectedTeam = newValue
            }
        }

        var standings: IdentifiedArrayOf<TeamStandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: competionStanding.table
                        .sorted(by: \.position)
                        .map(TeamStandingViewState.init)
                )
            }

            set {}
        }
    }

    public enum Action: Equatable {
        case selectTeamStanding(TeamStanding?)

        // Child actions
        case standingAction(id: TeamStandingViewState.ID, action: TeamStandingViewCell.Action)
        case teamAction(TeamView.Action)
    }

    public struct Environment {
        public var apiClient: FootballDataClient
        public var mainQueue: AnySchedulerOf<DispatchQueue>

        public init(apiClient: FootballDataClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.apiClient = apiClient
            self.mainQueue = mainQueue
        }
    }

    public static let reducer: Reducer<State, Action, Environment> = .combine(
        TeamStandingViewCell.reducer
            .forEach(
                state: \.standings,
                action: /Action.standingAction,
                environment: { _ in }
            ),

        TeamView.reducer
            .optional()
            .pullback(
                state: \.selectedTeam,
                action: /Action.teamAction,
                environment: {
                    TeamView.Environment(
                        apiClient: $0.apiClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),

        Reducer { state, action, environment in
            switch action {
            case .standingAction(let id, action: .selected):
                guard let teamStanding = state.competionStanding.table.first(where: { $0.team.id == id }) else {
                    return .none
                }

                return Effect(value: .selectTeamStanding(teamStanding))

            case .selectTeamStanding(let teamStanding):
                if let teamStanding = teamStanding {
                    state.selectedTeam = TeamView.State(
                        team: CompetitionTeam(
                            teamStanding.team,
                            competition: state.competionStanding.competition,
                            isFollowing: state.followingTeams.contains(where: { $0.id == teamStanding.team.id })
                        )
                    )
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
