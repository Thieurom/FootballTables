//
//  CompetitionMatchViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import CombineExt
import ComposableArchitecture
import SnapKit
import UIKit

class CompetitionMatchViewController: StoreViewController<CompetitionMatchView.State, CompetitionMatchView.ViewState, CompetitionMatchView.Action> {

    // MARK: - Views

    lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    lazy var dashboardTableView = UITableView().apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<CompetitionMatchView.ViewState.Section, MatchViewState>!

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

extension CompetitionMatchViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        // Layout
        view.addSubview(dashboardTableView)
        view.addSubview(loadingIndicator)

        dashboardTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        dashboardTableView.register(MatchViewCell.self, forCellReuseIdentifier: MatchViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<CompetitionMatchView.ViewState.Section, MatchViewState>(tableView: dashboardTableView) { [weak self] tableView, indexPath, itemState in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchViewCell.identifier, for: indexPath) as? MatchViewCell else {
                fatalError("Failed to dequeue cell of `MatchViewCell`")
            }

            cell.store = self?.store
                .scope(
                    state: { _ in itemState },
                    action: {
                        CompetitionMatchView.Action.matchAction(
                            id: itemState.id,
                            action: $0
                        )
                    }
                )

            return cell
        }

        dataSource.defaultRowAnimation = .fade
    }
}

// MARK: - Observe ViewStore

extension CompetitionMatchViewController {
    private func observeViewStore() {
        viewStore.publisher
            .title
            .map(Optional.some)
            .assign(to: \.title, on: self, ownership: .weak)
            .store(in: &cancellables)

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
            .matchSections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)
    }
}
