//
//  MatchViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 01/03/2022.
//

import FootballDataClient

public struct MatchViewState: Identifiable, Hashable {
    public let id: Int
    public let matchDay: String
    public let homeTeam: String
    public let awayTeam: String
    public let score: String

    public init(_ match: Match) {
        self.id = match.id
        self.matchDay = "Match Day \(match.matchDay)"
        self.homeTeam = match.homeTeam.name
        self.awayTeam = match.awayTeam.name

        if let homeScore = match.score.fullTime.homeTeam,
           let awayScore = match.score.fullTime.awayTeam {
            self.score = "\(homeScore)-\(awayScore)"
        } else {
            self.score = "-"
        }
    }
}
