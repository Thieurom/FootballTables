//
//  StandingDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import CommonExtensions
import ComposableExtensions
import CompetitionStandingView

extension StandingDashboardView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable, Identifiable {
            public let id: Int
            public let header: String
            public let subtitle: String
            public let items: [TeamStandingViewState]

            public init(id: Int, header: String, subtitle: String, items: [TeamStandingViewState]) {
                self.id = id
                self.header = header
                self.subtitle = subtitle
                self.items = items
            }
        }

        public let title: String
        public let sections: [Section]
        public let isShowingLoading: Bool
        public let isShowingError: Bool
        public let errorMessage: String?
        public let errorSystemImageName: String?
        public let retryButtonTitle: String

        public init(state: State) {
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

            self.isShowingLoading = state.isRequestInFlight
            self.isShowingError = !state.isRequestInFlight && state.error != nil
            self.errorMessage = state.error?.message
            self.errorSystemImageName = state.error != nil ? "exclamationmark.icloud" : nil
            self.retryButtonTitle = "RETRY"
        }
    }
}
