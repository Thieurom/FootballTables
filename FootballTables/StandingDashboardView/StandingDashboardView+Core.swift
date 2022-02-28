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
        let competitionIds: [Int]
        var isRequestInFlight: Bool = false
        var competionStandings = [CompetitionStanding]()

        var sections: IdentifiedArrayOf<ViewState.Section> {
            return IdentifiedArrayOf(
                uniqueElements: competionStandings
                    .map {
                        ViewState.Section(
                            id: $0.competitionId,
                            header: $0.competitionName,
                            items: $0.table.prefix(3).map(TeamStandingViewState.init(standing:))
                        )
                    }
            )
        }

        // A little bit hack?
        var sectionItems: IdentifiedArrayOf<TeamStandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: sections.elements.flatMap(\.items)
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
                state: \.sectionItems,
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

                case .teamStandingAction(let id, action: .selected):
                    // OMG!!!
                    guard let competitionStanding = state.competionStandings.first(where: { $0.table.contains(where: { $0.team.id == id }) }) else {
                        return .none
                    }
                    
                    return Effect(value: .selectCompetitionStanding(competitionStanding))

                case .teamStandingAction:
                    return .none

                case .competitionStandingAction:
                    return .none
                }
            }
    )
}
