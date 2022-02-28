//
//  TeamViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import SnapKit
import UIKit

class TeamViewController: StoreViewController<TeamView.State, TeamView.ViewState, TeamView.Action> {

    // MARK: - Views

    lazy var matchesTableView = UITableView().apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<TeamView.ViewState.Section, TeamView.ViewState.SectionItem>!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        observeViewStore()

        viewStore.send(.viewDidLoad)
    }
}

// MARK: - Setup

extension TeamViewController {
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(matchesTableView)

        matchesTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        matchesTableView.register(TeamDetailViewCell.self, forCellReuseIdentifier: TeamDetailViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<TeamView.ViewState.Section, TeamView.ViewState.SectionItem>(tableView: matchesTableView) { [weak self] tableView, indexPath, itemState in
            switch itemState {
            case .team(let team):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamDetailViewCell.identifier, for: indexPath) as? TeamDetailViewCell else {
                    fatalError("Failed to dequeue cell of `TeamDetailViewCell`")
                }

                cell.store = self?.store
                    .actionless
                    .scope(
                        state: { _ in team }
                    )

                return cell
            }
        }

        dataSource.defaultRowAnimation = .fade
    }
}

// MARK: - Observe ViewStore

extension TeamViewController {
    private func observeViewStore() {
        viewStore.publisher
            .sections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)
    }
}
