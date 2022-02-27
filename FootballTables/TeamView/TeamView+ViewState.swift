//
//  TeamView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import FootballDataClient
import CombineDataSources
import Foundation

extension TeamView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            var items: [TeamView.ViewState.SectionItem]
        }

        enum SectionItem: Hashable {
            case team(TeamDetailViewState)
        }

        let teamName: String?
        let teamLogoUrl: URL?
        let sections: [Section]

        init(state: State) {
            self.teamName = state.team.name
            self.teamLogoUrl = state.team.crestUrl
            self.sections = Self.buildSections(team: state.team)
        }
    }
}

struct TeamDetailViewState: Identifiable, Hashable {
    let id: Int
    let teamName: String?
    let teamLogoUrl: URL?

    init(team: ShortTeam) {
        self.id = team.id
        self.teamName = team.name
        self.teamLogoUrl = team.crestUrl
    }
}

extension TeamView.ViewState {
    fileprivate static func buildSections(team: ShortTeam) -> [Section] {
        let teamSectionItem = SectionItem.team(TeamDetailViewState(team: team))

        return [
            .init(items: [teamSectionItem])
        ]
    }
}
