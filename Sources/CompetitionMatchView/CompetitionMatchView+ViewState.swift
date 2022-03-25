//
//  CompetitionMatchView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import CommonExtensions
import ComposableExtensions
import Foundation
import MatchViewCell

extension CompetitionMatchView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable {
            public let items: [MatchViewState]
        }

        public let title: String
        public let matchSections: [Section]
        public let isShowingLoading: Bool
        public let isShowingError: Bool
        public let errorMessage: String?
        public let errorSystemImageName: String?
        public let retryButtonTitle: String

        public init(state: State) {
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
