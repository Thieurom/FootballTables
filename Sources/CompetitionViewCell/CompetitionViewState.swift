//
//  CompetitionViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import Foundation
import FootballDataClient

public struct CompetitionViewState: Identifiable, Hashable {
    public let id: Int
    public let competitionName: String
    public let competitionLogoUrl: URL?

    public init(_ competition: Competition) {
        self.id = competition.id
        self.competitionName = competition.name
        self.competitionLogoUrl = competition.ensignUrl
    }
}
