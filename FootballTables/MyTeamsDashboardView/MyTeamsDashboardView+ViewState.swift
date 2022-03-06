//
//  MyTeamsDashboardView+ViewState.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

extension MyTeamsDashboardView {
    struct ViewState: StoreViewState {
        let title: String
        init(state: State) {
            // TODO:
            self.title = "My Teams"
        }
    }
}
