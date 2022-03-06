//
//  CompetitionViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import Foundation
import FootballDataClient

struct CompetitionViewState: Identifiable, Hashable {
    let id: Int
    let competitionName: String
    let competitionLogoUrl: URL?

    init(_ competition: Competition) {
        self.id = competition.id
        self.competitionName = competition.name
        self.competitionLogoUrl = competition.ensignUrl
    }
}
