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
        let isShowingLoading: Bool
        let isShowingError: Bool
        let errorMessage: String?
        let errorSystemImageName: String?
        let retryButtonTitle: String

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

            self.isShowingLoading = state.isRequestInFlight
            self.isShowingError = !state.isRequestInFlight && state.error != nil
            self.errorMessage = state.error?.message
            self.errorSystemImageName = state.error != nil ? "exclamationmark.icloud" : nil
            self.retryButtonTitle = "RETRY"
        }
    }
}
