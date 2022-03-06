//
//  MatchDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import FootballDataClient
import Foundation

extension MatchDashboardView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            let items: [SectionItem]
        }

        enum SectionItem: Hashable {
            case competition(CompetitionViewState)
            case match(MatchViewState)
        }

        let title: String
        let sections: [Section]
        let isRequestInFlight: Bool

        init(state: State) {
            self.title = "Matches"

            self.sections = state.matchSections
                .map {
                    Section(
                        items: [.competition(CompetitionViewState($0.competition))]
                        + $0.matches.map { .match(MatchViewState.init($0))}
                    )
                }

            self.isRequestInFlight = state.isRequestInFlight
        }
    }
}
