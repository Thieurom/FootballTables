//
//  MyTeamsDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

extension MyTeamsDashboardView {
    struct ViewState: StoreViewState {
        struct Section: Sectionable {
            let items: [FollowingTeamViewState]
        }

        let title: String
        let sections: [Section]
        let placeholderImageName: String
        let placeholderMessage: String
        let isShowingPlaceholder: Bool

        init(state: State) {
            self.title = "My Teams"
            self.sections = [
                .init(items: state.followingTeams.map(FollowingTeamViewState.init))
            ]

            self.placeholderImageName = "square.grid.3x2"
            self.placeholderMessage = "Your favorite teams appear here!"
            self.isShowingPlaceholder = state.followingTeams.isEmpty
        }
    }
}
