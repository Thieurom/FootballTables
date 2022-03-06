//
//  MatchDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CombineExt
import ComposableArchitecture
import FootballDataClient

struct MatchDashboardView {
    struct State: Equatable {
        struct MatchSection: Equatable {
            let competition: Competition
            let matches: [Match]

            init(competition: Competition, matches: [Match]) {
                self.competition = competition
                self.matches = matches
            }
        }

        let competitionIds: [Int]
        var matches: [[Match]] = []
        var isRequestInFlight: Bool = false

        var matchSections: [MatchSection] {
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

        var matchViewStates: IdentifiedArrayOf<MatchViewState> {
            get {
                IdentifiedArray(
                    uniqueElements: matchSections
                        .flatMap(\.matches)
                        .map(MatchViewState.init)
                )
            }

            set {}
        }

        var competitionViewStates: IdentifiedArrayOf<CompetitionViewState> {
            get {
                IdentifiedArray(
                    uniqueElements: matchSections
                        .map(\.competition)
                        .map(CompetitionViewState.init)
                )
            }

            set {}
        }

        var selectedCompetitionMatch: CompetitionMatchView.State?
    }

    enum Action: Equatable {
        case viewDidLoad
        case competitionsResponse(Result<[[Match]], ApiError>)
        case selectCompetition(Competition?)

        // Child actions
        case matchAction(id: MatchViewState.ID, action: MatchViewCell.Action)
        case competitionAction(id: CompetitionViewState.ID, action: CompetitionViewCell.Action)
        case competitionMatchAction(CompetitionMatchView.Action)
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        MatchViewCell.reducer
            .forEach(
                state: \.matchViewStates,
                action: /Action.matchAction,
                environment: { _ in
                    MatchViewCell.Environment()
                }
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

        .init { state, action, environment in
            switch action {
            case .viewDidLoad:
                state.isRequestInFlight = true

                return state.competitionIds
                    .removeAllDuplicates()
                    .map {
                        environment.apiClient
                            .fetchMatches(competitionId: $0)
                    }
                    .combineLatest()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(Action.competitionsResponse)

            case .competitionsResponse(.success(let matches)):
                state.isRequestInFlight = false
                state.matches = matches
                return .none

            case .competitionsResponse(.failure):
                state.isRequestInFlight = false
                state.matches = []
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
