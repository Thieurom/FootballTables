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

    lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

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
        view.addSubview(loadingIndicator)

        matchesTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        matchesTableView.register(TeamDetailViewCell.self, forCellReuseIdentifier: TeamDetailViewCell.identifier)
        matchesTableView.register(MatchViewCell.self, forCellReuseIdentifier: MatchViewCell.identifier)
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

            case .match(let match):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchViewCell.identifier, for: indexPath) as? MatchViewCell else {
                    fatalError("Failed to dequeue cell of `MatchViewCell`")
                }

                cell.store = self?.store
                    .scope(
                        state: { _ in match },
                        action: {
                            TeamView.Action.matchAction(
                                id: match.id,
                                action: $0
                            )
                        }
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
            .isRequestInFlight
            .sink { [weak self] in
                if $0 {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewStore.publisher
            .sections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)
    }
}
