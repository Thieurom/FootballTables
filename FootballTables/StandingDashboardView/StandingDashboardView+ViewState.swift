//
//  StandingDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import FootballDataClient

extension StandingDashboardView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable, Identifiable {
            let id: Int
            let header: String
            let items: [TeamStandingViewState]
        }

        let title: String
        let standingItems: [Section]
        let isRequestInFlight: Bool

        init(state: State) {
            self.title = "Standings"
            self.standingItems = state.sections.elements
            self.isRequestInFlight = state.isRequestInFlight
        }
    }
}
