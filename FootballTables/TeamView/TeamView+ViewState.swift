//
//  TeamView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import FootballDataClient
import Foundation

extension TeamView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            let items: [TeamView.ViewState.SectionItem]
        }

        enum SectionItem: Hashable {
            case team(TeamDetailViewState)
            case match(MatchViewState)
        }

        let sections: [Section]
        let isShowingLoading: Bool
        let isShowingError: Bool
        let errorMessage: String?
        let errorSystemImageName: String?
        let retryButtonTitle: String

        init(state: State) {
            let finishedMatches = state.matches
                .filter { $0.status == .finished }
                .sorted { $0.matchDay > $1.matchDay }

            self.sections = [
                Self.buildTeamSection(
                    teamStanding: state.teamStanding,
                    competitionName: state.competition.name
                ),
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

struct TeamDetailViewState: Identifiable, Hashable {
    let id: Int
    let teamName: String
    let teamLogoUrl: URL?
    let position: String
}

extension TeamView.ViewState {
    fileprivate static func buildTeamSection(teamStanding: TeamStanding, competitionName: String) -> Section {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .ordinal

        let _position = numberFormatter.string(from: NSNumber(value: teamStanding.position))!
        let position = "\(_position) - \(competitionName)"

        let teamDetail = TeamDetailViewState(
            id: teamStanding.team.id,
            teamName: teamStanding.team.name,
            teamLogoUrl: teamStanding.team.crestUrl,
            position: position
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
