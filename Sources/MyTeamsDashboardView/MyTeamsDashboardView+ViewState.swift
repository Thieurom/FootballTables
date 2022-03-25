//
//  MyTeamsDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import CommonExtensions
import ComposableExtensions
import FollowingTeamViewCell

extension MyTeamsDashboardView {
    public struct ViewState: StoreViewState {
        public struct Section: Sectionable {
            public let items: [FollowingTeamViewState]

            public init(items: [FollowingTeamViewState]) {
                self.items = items
            }
        }

        public let title: String
        public let sections: [Section]
        public let placeholderImageName: String
        public let placeholderMessage: String
        public let isShowingPlaceholder: Bool

        public init(state: State) {
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
