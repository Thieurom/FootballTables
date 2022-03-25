//
//  FollowingTeamViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 14/03/2022.
//

import Foundation
import Models

public struct FollowingTeamViewState: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let logoUrl: URL?

    public init(_ team: CompetitionTeam) {
        self.id = team.id
        self.name = team.name
        self.logoUrl = team.crestUrl
    }
}
