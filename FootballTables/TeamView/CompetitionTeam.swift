//
//  CompetitionTeam.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 20/03/2022.
//

import FootballDataClient
import Foundation

struct CompetitionTeam: Equatable {
    let id: Int
    let name: String
    let crestUrl: URL?
    let competingCompetition: Competition
    var isFollowing: Bool

    init(_ shortTeam: ShortTeam, competition: Competition, isFollowing: Bool) {
        self.id = shortTeam.id
        self.name = shortTeam.name
        self.crestUrl = shortTeam.crestUrl
        self.competingCompetition = competition
        self.isFollowing = isFollowing
    }
}
