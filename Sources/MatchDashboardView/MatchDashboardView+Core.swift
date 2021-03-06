//
//  MatchDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CombineExt
import ComposableArchitecture
import CompetitionMatchView
import CompetitionViewCell
import FootballDataClient
import MatchViewCell
import Models

public struct MatchDashboardView {
    public struct State: Equatable {
        public struct MatchSection: Equatable {
            public let competition: Competition
            public let matches: [Match]

            public init(competition: Competition, matches: [Match]) {
                self.competition = competition
                self.matches = matches
            }
        }

        public let competitionIds: [Int]
        public var matches: [[Match]]
        public var error: AppError?
        public var isRequestInFlight: Bool

        public init(competitionIds: [Int]) {
            self.competitionIds = competitionIds
            self.matches = []
            self.error = nil
            self.isRequestInFlight = false
            self.selectedCompetitionMatch = nil
        }

        public var matchSections: [MatchSection] {
            return matches
                .compactMap { matches in
                    guard let firstMatch = matches.first else {
                        return nil
                    }

                    return (
                        firstMatch.competition,
                        Array(
                            matches.filter { $0.matchDay == $0.season.currentMatchday }
                                .sorted { $0.date > $1.date }
                                .prefix(3)
                        )
                    )
                }
                .map { MatchSection(competition: $0, matches: $1) }
        }

        // Child states

        public var matchViewStates: IdentifiedArrayOf<MatchViewState> {
            get {
                IdentifiedArray(
                    uniqueElements: matchSections
                        .flatMap(\.matches)
                        .map(MatchViewState.init)
                )
            }

            set {}
        }

        public var competitionViewStates: IdentifiedArrayOf<CompetitionViewState> {
            get {
                IdentifiedArray(
                    uniqueElements: matchSections
                        .map(\.competition)
                        .map(CompetitionViewState.init)
                )
            }

            set {}
        }

        public var selectedCompetitionMatch: CompetitionMatchView.State?
    }

    public enum Action: Equatable {
        case fetchMatches
        case matchesResponse(Result<[[Match]], ApiError>)
        case selectCompetition(Competition?)

        // Child actions
        case matchAction(id: MatchViewState.ID, action: MatchViewCell.Action)
        case competitionAction(id: CompetitionViewState.ID, action: CompetitionViewCell.Action)
        case competitionMatchAction(CompetitionMatchView.Action)
    }

    public struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
        
        public init(apiClient: FootballDataClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.apiClient = apiClient
            self.mainQueue = mainQueue
        }
    }

    public static let reducer = Reducer<State, Action, Environment>.combine(
        MatchViewCell.reducer
            .forEach(
                state: \.matchViewStates,
                action: /Action.matchAction,
                environment: { _ in }
            ),

        CompetitionMatchView.reducer
            .optional()
            .pullback(
                state: \.selectedCompetitionMatch,
                action: /Action.competitionMatchAction,
                environment: {
                    CompetitionMatchView.Environment(
                        apiClient: $0.apiClient,
                        mainQueue: $0.mainQueue
                    )
                }
            ),

        Reducer { state, action, environment in
            struct CancelId: Hashable {}

            switch action {
            case .fetchMatches:
                state.isRequestInFlight = true

                return state.competitionIds
                    .removeAllDuplicates()
                    .map {
                        environment.apiClient.fetchMatches(competitionId: $0)
                    }
                    .combineLatest()
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

            case .selectCompetition(let competition):
                if let competition = competition {
                    state.selectedCompetitionMatch = CompetitionMatchView.State(
                        competition: competition
                    )
                } else {
                    state.selectedCompetitionMatch = nil
                }

                return .none

            case .matchAction(let id, action: .selected):
                guard let section = state.matchSections.first(where: { $0.matches.contains(where: { $0.id == id }) }) else {
                    return .none
                }

                return Effect(value: .selectCompetition(section.competition))

            case .competitionAction(let id, action: .selected):
                guard let section = state.matchSections.first(where: { $0.competition.id == id }) else {
                    return .none
                }

                return Effect(value: .selectCompetition(section.competition))

            case .competitionMatchAction:
                return .none
            }
        }
    )
}
