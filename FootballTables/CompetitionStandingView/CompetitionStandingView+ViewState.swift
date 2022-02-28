//
//  CompetitionStandingView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import FootballDataClient
import Foundation

extension CompetitionStandingView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            let items: [TeamStandingViewState]
        }

        let leagueName: String?
        let standings: [Section]

        init(state: State) {
            self.leagueName = state.competionStanding.competitionName
            self.standings = [Section(items: state.standings.map { $0 })]
        }
    }
}

struct TeamStandingViewState: Identifiable, Hashable {
    let id: Int
    let name: String
    let position: String
    let points: String
    let logoUrl: URL?

    init(standing: Standing) {
        self.id = standing.team.id
        self.name = standing.team.name
        self.position = "\(standing.position)"
        self.points = "\(standing.points)"
        self.logoUrl = standing.team.crestUrl
    }
}
