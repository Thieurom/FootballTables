//
//  CompetitionTeam.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 20/03/2022.
//

import FootballDataClient
import Foundation

public struct CompetitionTeam: Equatable {
    public let id: Int
    public let name: String
    public let crestUrl: URL?
    public let competingCompetition: Competition
    public var isFollowing: Bool

    public init(_ shortTeam: ShortTeam, competition: Competition, isFollowing: Bool) {
        self.id = shortTeam.id
        self.name = shortTeam.name
        self.crestUrl = shortTeam.crestUrl
        self.competingCompetition = competition
        self.isFollowing = isFollowing
    }
}
