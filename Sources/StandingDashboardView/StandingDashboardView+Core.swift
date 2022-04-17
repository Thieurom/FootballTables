//
//  StandingDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import CombineExt
import ComposableArchitecture
import CompetitionStandingView
import FootballDataClient
import Models

public struct StandingDashboardView {
    public struct State: Equatable {
        public struct StandingSection: Equatable {
            public let competitionStanding: CompetitionStanding
            public let standings: [TeamStanding]

            public init(competitionStanding: CompetitionStanding, standings: [TeamStanding]) {
                self.competitionStanding = competitionStanding
                self.standings = standings
            }
        }

        public let competitionIds: [Int]
        public var followingTeams: [CompetitionTeam]
        public var competionStandings: [CompetitionStanding]
        public var error: AppError?
        public var isRequestInFlight: Bool

        public init(competitionIds: [Int], followingTeams: [CompetitionTeam]) {
            self.competitionIds = competitionIds
            self.followingTeams = followingTeams
            self.competionStandings = []
            self.error = nil
            self.isRequestInFlight = false
            self._selectedCompetitionStanding = nil
        }

        public var standingSections: [StandingSection] {
            return competionStandings
                .map {
                    StandingSection(
                        competitionStanding: $0,
                        standings: Array($0.table.prefix(4))
                    )
                }
        }

        // Child states
        
        public var teamStandingViewStates: IdentifiedArrayOf<TeamStandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: standingSections
                        .flatMap(\.standings)
                        .map(TeamStandingViewState.init)
                )
            }
            set {}
        }

        var _selectedCompetitionStanding: CompetitionStandingView.State?

        public var selectedCompetitionStanding: CompetitionStandingView.State? {
            get {
                return _selectedCompetitionStanding
            }
            set {
                if let updatedFollowingTeams = newValue?.followingTeams {
                    followingTeams = updatedFollowingTeams
                }
                _selectedCompetitionStanding = newValue
            }
        }
    }

    public enum Action: Equatable {
        case fetchCompetitionStanding
        case competitionStandingsResponse(Result<[CompetitionStanding], ApiError>)
        case selectCompetitionStanding(CompetitionStanding?)
        case selectSectionHeader(Int)

        // Child actions
        case teamStandingAction(id: TeamStandingViewState.ID, action: TeamStandingViewCell.Action)
        case competitionStandingAction(CompetitionStandingView.Action)
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
                state: \.teamStandingViewStates,
                action: /Action.teamStandingAction,
                environment: { _ in }
            ),

        CompetitionStandingView.reducer
            .optional()
            .pullback(
                state: \.selectedCompetitionStanding,
                action: /Action.competitionStandingAction,
                environment: {
                    CompetitionStandingView.Environment(
                        apiClient: $0.apiClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),

        Reducer { state, action, environment in
            struct CancelId: Hashable {}

            switch action {
            case .fetchCompetitionStanding:
                state.isRequestInFlight = true

                return state.competitionIds
                    .removeAllDuplicates()
                    .map {
                        environment.apiClient.fetchStanding(competitionId: $0)
                    }
                    .combineLatest()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(Action.competitionStandingsResponse)
                    .cancellable(id: CancelId(), cancelInFlight: true)

            case .competitionStandingsResponse(.success(let standings)):
                state.isRequestInFlight = false
                state.competionStandings = standings
                state.error = nil
                return .none

            case .competitionStandingsResponse(.failure):
                state.isRequestInFlight = false
                state.competionStandings = []
                state.error = AppError(message: "There's a problem fetching data!")
                return .none

            case .selectCompetitionStanding(let competitionStanding):
                if let competitionStanding = competitionStanding {
                    state.selectedCompetitionStanding = CompetitionStandingView.State(
                        competionStanding: competitionStanding,
                        followingTeams: state.followingTeams
                    )
                } else {
                    state.selectedCompetitionStanding = nil
                }
                return .none

            case .selectSectionHeader(let section):
                guard (0..<state.standingSections.count) ~= section else {
                    return .none
                }

                let standingSection = state.standingSections[section]
                return Effect(value: .selectCompetitionStanding(standingSection.competitionStanding))

            case .teamStandingAction(let id, action: .selected):
                // OMG!!!
                guard let section = state.standingSections.first(where: { $0.standings.contains(where: { $0.team.id == id }) }) else {
                    return .none
                }

                return Effect(value: .selectCompetitionStanding(section.competitionStanding))

            case .teamStandingAction:
                return .none

            case .competitionStandingAction:
                return .none
            }
        }
    )
}
