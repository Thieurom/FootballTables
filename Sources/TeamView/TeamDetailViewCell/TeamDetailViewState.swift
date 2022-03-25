//
//  TeamDetailViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 17/03/2022.
//

import Foundation
import Models

public struct TeamDetailViewState: Identifiable, Hashable {
    public let id: Int
    public let teamName: String
    public let teamLogoUrl: URL?
    public let competitionName: String
    public let isFollowing: Bool

    public var followingStatusTitle: String {
        isFollowing ? "Following" : "Follow"
    }

    public init(team: CompetitionTeam) {
        self.id = team.id
        self.teamName = team.name
        self.teamLogoUrl = team.crestUrl
        self.competitionName = team.competingCompetition.name
        self.isFollowing = team.isFollowing
    }
}
