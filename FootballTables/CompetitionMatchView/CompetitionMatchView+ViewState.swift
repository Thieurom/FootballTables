//
//  CompetitionMatchView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import Foundation

extension CompetitionMatchView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            let items: [MatchViewState]
        }

        let title: String
        let matchSections: [Section]
        let isRequestInFlight: Bool

        init(state: State) {
            self.title = state.competition.name

            self.matchSections = [
                .init(
                    items: state.matches
                        .filter { $0.matchDay == $0.season.currentMatchday }
                        .sorted { $0.date > $1.date }
                        .map(MatchViewState.init)
                )
            ]

            self.isRequestInFlight = state.isRequestInFlight
        }
    }
}
