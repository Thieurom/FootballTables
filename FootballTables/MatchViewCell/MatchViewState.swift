//
//  MatchViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 01/03/2022.
//

import FootballDataClient

struct MatchViewState: Identifiable, Hashable {
    let id: Int
    let matchDay: String
    let homeTeam: String
    let awayTeam: String
    let score: String

    init(match: Match) {
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
