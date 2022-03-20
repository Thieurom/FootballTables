//
//  TeamDetailViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 17/03/2022.
//

import Foundation
import FootballDataClient

struct TeamDetailViewState: Identifiable, Hashable {
    let id: Int
    let teamName: String
    let teamLogoUrl: URL?
    let competitionName: String
    let isFollowing: Bool

    var followingStatusTitle: String {
        isFollowing ? "Following" : "Follow"
    }

    init(team: CompetitionTeam) {
        self.id = team.id
        self.teamName = team.name
        self.teamLogoUrl = team.crestUrl
        self.competitionName = team.competingCompetition.name
        self.isFollowing = team.isFollowing
    }
}
