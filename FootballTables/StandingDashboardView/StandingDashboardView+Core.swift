//
//  StandingDashboardView+Core.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import CombineExt
import ComposableArchitecture
import FootballDataClient
import IdentifiedCollections

struct StandingDashboardView {
    struct State: Equatable {
        struct StandingSection: Equatable {
            let competitionStanding: CompetitionStanding
            let standings: [TeamStanding]
        }

        let competitionIds: [Int]
        var isRequestInFlight: Bool = false
        var competionStandings = [CompetitionStanding]()

        var standingSections: [StandingSection] {
            return competionStandings
                .map {
                    StandingSection(
                        competitionStanding: $0,
                        standings: Array($0.table.prefix(4))
                    )
                }
        }

        // Child states
        
        var teamStandingViewStates: IdentifiedArrayOf<TeamStandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: standingSections
                        .flatMap(\.standings)
                        .map(TeamStandingViewState.init)
                )
            }
            set {}
        }

        var selectedCompetitionStanding: CompetitionStandingView.State?
    }

    enum Action: Equatable {
        case viewDidLoad
        case competitionStandingsResponse(Result<[CompetitionStanding], ApiError>)
        case selectCompetitionStanding(CompetitionStanding?)
        case selectSectionHeader(Int)

        // Child actions
        case teamStandingAction(id: TeamStandingViewState.ID, action: TeamStandingViewCell.Action)
        case competitionStandingAction(CompetitionStandingView.Action)
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer: Reducer<State, Action, Environment> = .combine(
        TeamStandingViewCell.reducer
            .forEach(
                state: \.teamStandingViewStates,
                action: /Action.teamStandingAction,
                environment: { _ in TeamStandingViewCell.Environment() }
            ),

        CompetitionStandingView.reducer
            .optional()
            .pullback(
                state: \.selectedCompetitionStanding,
                action: /Action.competitionStandingAction,
                environment: { _ in CompetitionStandingView.Environment() }),

            .init { state, action, environment in
                struct CompetionRequestId: Hashable {}

                switch action {
                case .viewDidLoad:
                    state.isRequestInFlight = true

                    return state.competitionIds
                        .removeAllDuplicates()
                        .map {
                            environment.apiClient.fetchStanding(competitionId: $0)
                        }
                        .combineLatest()
                        .receive(on: environment.mainQueue)
                        .catchToEffect(Action.competitionStandingsResponse)
                        .cancellable(id: CompetionRequestId(), cancelInFlight: true)
                    
                case .competitionStandingsResponse(.success(let standings)):
                    state.isRequestInFlight = false
                    state.competionStandings = standings
                    return .none

                case .competitionStandingsResponse(.failure):
                    state.isRequestInFlight = false
                    state.competionStandings = []
                    return .none

                case .selectCompetitionStanding(let competitionStanding):
                    if let competitionStanding = competitionStanding {
                        state.selectedCompetitionStanding = CompetitionStandingView.State(
                            competionStanding: competitionStanding
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
