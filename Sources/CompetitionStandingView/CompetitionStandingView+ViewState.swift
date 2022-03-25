//
//  CompetitionStandingView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import CommonExtensions
import ComposableExtensions
import FootballDataClient
import Foundation

extension CompetitionStandingView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable {
            public let items: [TeamStandingViewState]
        }

        public let leagueName: String?
        public let standings: [Section]

        public init(state: State) {
            self.leagueName = state.competionStanding.competition.name
            self.standings = [Section(items: state.standings.map { $0 })]
        }
    }
}

public struct TeamStandingViewState: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let position: String
    public let points: String
    public let logoUrl: URL?

    public init(_ standing: TeamStanding) {
        self.id = standing.team.id
        self.name = standing.team.name
        self.position = "\(standing.position)"
        self.points = "\(standing.points)"
        self.logoUrl = standing.team.crestUrl
    }
}
