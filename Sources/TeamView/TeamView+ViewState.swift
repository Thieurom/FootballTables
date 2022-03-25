//
//  TeamView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import CommonExtensions
import ComposableExtensions
import FootballDataClient
import Foundation
import MatchViewCell
import Models

extension TeamView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable {
            public let items: [TeamView.ViewState.SectionItem]
        }

        public enum SectionItem: Hashable {
            case team(TeamDetailViewState)
            case match(MatchViewState)
        }

        public let sections: [Section]
        public let isShowingLoading: Bool
        public let isShowingError: Bool
        public let errorMessage: String?
        public let errorSystemImageName: String?
        public let retryButtonTitle: String

        public init(state: State) {
            let finishedMatches = state.matches
                .filter { $0.status == .finished }
                .sorted { $0.matchDay > $1.matchDay }

            self.sections = [
                Self.buildTeamSection(team: state.team),
                Self.buildMatchesSections(matches: finishedMatches)
            ]

            self.isShowingLoading = state.isRequestInFlight
            self.isShowingError = !state.isRequestInFlight && state.error != nil
            self.errorMessage = state.error?.message
            self.errorSystemImageName = state.error != nil ? "exclamationmark.icloud" : nil
            self.retryButtonTitle = "RETRY"
        }
    }
}

extension TeamView.ViewState {
    fileprivate static func buildTeamSection(team: CompetitionTeam) -> Section {
        let teamDetail = TeamDetailViewState(
            team: team
        )

        return .init(items: [SectionItem.team(teamDetail)])
    }

    fileprivate static func buildMatchesSections(matches: [Match]) -> Section {
        let matchesSection = matches
            .map(MatchViewState.init)
            .map { SectionItem.match($0) }

        return .init(items: matchesSection)
    }
}
