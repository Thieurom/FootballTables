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

    lazy var placeholderImageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    lazy var placeholderLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 20)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
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

        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)

        placeholderImageView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(placeholderImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
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

        // TODO:
        placeholderImageView.image = UIImage(systemName: "square.grid.3x2")
        placeholderImageView.tintColor = .gray
        placeholderLabel.text = "Your favorite teams appear here!".uppercased()
    }
}
