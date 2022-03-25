//
//  MyTeamsDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import ComposableArchitecture
import FollowingTeamViewCell
import FootballDataClient
import Models
import TeamView

public struct MyTeamsDashboardView {
    public struct State: Equatable {
        public var followingTeams: [CompetitionTeam]

        public init(followingTeams: [CompetitionTeam]) {
            self.followingTeams = followingTeams
        }

        // Child states

        var _selectedTeam: TeamView.State?
        public var selectedTeam: TeamView.State? {
            get {
                return _selectedTeam
            }
            set {
                if let teamViewState = newValue,
                   !teamViewState.team.isFollowing {
                    followingTeams.removeAll(where: { $0.id == teamViewState.team.id })
                }
                _selectedTeam = newValue
            }
        }

        public var followingTeamViewStates: IdentifiedArrayOf<FollowingTeamViewState> {
            get {
                .init(
                    uniqueElements: followingTeams.map(FollowingTeamViewState.init)
                )
            }
            set {}
        }
    }

    public enum Action: Equatable {
        case selectTeam(CompetitionTeam?)

        // Child actions
        case followingTeamAction(id: FollowingTeamViewState.ID, action: FollowingTeamViewCell.Action)
        case selectedTeamAction(TeamView.Action)
    }

    public struct Environment {
        public var apiClient: FootballDataClient
        public var mainQueue: AnySchedulerOf<DispatchQueue>
        
        public init(apiClient: FootballDataClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.apiClient = apiClient
            self.mainQueue = mainQueue
        }
    }

    public static let reducer = Reducer<State, Action, Environment>.combine(
        FollowingTeamViewCell.reducer
            .forEach(
                state: \.followingTeamViewStates,
                action: /Action.followingTeamAction,
                environment: { _ in }
            ),

        TeamView.reducer
            .optional()
            .pullback(
                state: \.selectedTeam,
                action: /Action.selectedTeamAction,
                environment: {
                    TeamView.Environment(
                        apiClient: $0.apiClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),

        Reducer { state, action, environment in
            switch action {
            case .selectTeam(let team):
                if let team = team {
                    state.selectedTeam = TeamView.State(team: team)
                } else {
                    state.selectedTeam = nil
                }
                return .none

            case .followingTeamAction(let id, action: .selected):
                guard let teamViewState = state.followingTeamViewStates[id: id],
                      let team = state.followingTeams.first(where: { $0.id == teamViewState.id }) else {
                    return .none
                }
                return Effect(value: .selectTeam(team))

            case .selectedTeamAction(.teamDetailAction(.followButtonTapped)):
                state.selectedTeam = nil
                return .none

            case .selectedTeamAction:
                return .none
            }
        }
    )
}
