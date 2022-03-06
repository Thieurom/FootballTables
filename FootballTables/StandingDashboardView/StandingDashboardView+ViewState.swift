//
//  StandingDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

extension StandingDashboardView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable, Identifiable {
            let id: Int
            let header: String
            let subtitle: String
            let items: [TeamStandingViewState]
        }

        let title: String
        let sections: [Section]
        let isRequestInFlight: Bool

        init(state: State) {
            self.title = "Standings"

            self.sections = state.standingSections
                .map {
                    Section(
                        id: $0.competitionStanding.competition.id,
                        header: $0.competitionStanding.competition.name,
                        subtitle: "See All",
                        items: $0.standings.map(TeamStandingViewState.init)
                    )
                }

            self.isRequestInFlight = state.isRequestInFlight
        }
    }
}
