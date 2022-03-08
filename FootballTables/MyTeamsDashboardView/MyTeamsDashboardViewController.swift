//
//  MyTeamsDashboardViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 06/03/2022.
//

import CombineExt
import SnapKit
import UIKit

class MyTeamsDashboardViewController: StoreViewController<MyTeamsDashboardView.State, MyTeamsDashboardView.ViewState, MyTeamsDashboardView.Action> {

    // MARK: - Views

    lazy var placeholderView = MessageView().apply {
        $0.titleLabel.textColor = .gray
        $0.imageView.tintColor = .gray
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        observeViewStore()

        viewStore.send(.viewDidLoad)
    }
}

// MARK: - Setup

extension MyTeamsDashboardViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .theme
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(placeholderView)

        placeholderView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}

// MARK: - Observe ViewStore

extension MyTeamsDashboardViewController {
    private func observeViewStore() {
        viewStore.publisher
            .title
            .map(Optional.some)
            .assign(to: \.title, on: self, ownership: .weak)
            .store(in: &cancellables)

        placeholderView.setImage(UIImage(systemName: "square.grid.3x2")!)
        placeholderView.setTitle("Your favorite teams appear here!")
    }
}
