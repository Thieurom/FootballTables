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
        let competitionId: Int
        var isRequestInFlight: Bool = false
        var competionStanding: CompetitionStanding?
        var selectedTeam: TeamView.State?

        var standings: IdentifiedArrayOf<StandingViewState> {
            get {
                IdentifiedArrayOf(
                    uniqueElements: (competionStanding?.table ?? []).sorted(by: \.position).map(StandingViewState.init(standing:))
                )
            }

            set {}
        }
    }

    enum Action: Equatable {
        case viewDidLoad
        case competitionStandingResponse(Result<CompetitionStanding, ApiError>)
        case standingAction(id: StandingViewState.ID, action: StandingViewCell.Action)
        case selectTeam(ShortTeam?)
        case teamAction(TeamView.Action)
    }

    struct Environment {
        var apiClient: FootballDataClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    static let reducer: Reducer<State, Action, Environment> = .combine(
        StandingViewCell.reducer
            .forEach(
                state: \.standings,
                action: /Action.standingAction,
                environment: { _ in StandingViewCell.Environment() }
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
            case .viewDidLoad:
                state.isRequestInFlight = true

                return environment.apiClient
                    .fetchStanding(competitionId: state.competitionId)
                    .receive(on: environment.mainQueue)
                    .catchToEffect(Action.competitionStandingResponse)
                    .cancellable(id: CompetionRequestId(), cancelInFlight: true)

            case .competitionStandingResponse(.success(let standing)):
                state.isRequestInFlight = false
                state.competionStanding = standing
                return .none

            case .competitionStandingResponse(.failure):
                state.isRequestInFlight = false
                state.competionStanding = nil
                return .none

            case .standingAction(let id, action: .selected):
                guard let standing = state.competionStanding?.table.first(where: { $0.team.id == id }) else {
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
