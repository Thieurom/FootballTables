//
//  MatchDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CommonExtensions
import CompetitionViewCell
import ComposableExtensions
import FootballDataClient
import Foundation
import MatchViewCell

extension MatchDashboardView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable {
            public let items: [SectionItem]
        }

        public enum SectionItem: Hashable {
            case competition(CompetitionViewState)
            case match(MatchViewState)
        }

        public let title: String
        public let sections: [Section]
        public let isShowingLoading: Bool
        public let isShowingError: Bool
        public let errorMessage: String?
        public let errorSystemImageName: String?
        public let retryButtonTitle: String

        public init(state: State) {
            self.title = "Matches"

            self.sections = state.matchSections
                .map {
                    Section(
                        items: [.competition(CompetitionViewState($0.competition))]
                        + $0.matches.map { .match(MatchViewState.init($0))}
                    )
                }

            self.isShowingLoading = state.isRequestInFlight
            self.isShowingError = !state.isRequestInFlight && state.error != nil
            self.errorMessage = state.error?.message
            self.errorSystemImageName = state.error != nil ? "exclamationmark.icloud" : nil
            self.retryButtonTitle = "RETRY"
        }
    }
}
