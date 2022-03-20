//
//  FollowingTeamViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 14/03/2022.
//

import Foundation
import FootballDataClient

struct FollowingTeamViewState: Identifiable, Hashable {
    let id: Int
    let name: String
    let logoUrl: URL?

    init(_ team: CompetitionTeam) {
        self.id = team.id
        self.name = team.name
        self.logoUrl = team.crestUrl
    }
}
