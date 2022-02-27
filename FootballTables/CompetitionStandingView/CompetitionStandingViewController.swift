//
//  CompetitionStandingViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import SnapKit
import UIKit

class CompetitionStandingViewController: StoreViewController<CompetitionStandingView.State, CompetitionStandingView.ViewState, CompetitionStandingView.Action> {

    // MARK: - Views

    lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    lazy var standingTableView = UITableView().apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<CompetitionStandingView.ViewState.Section, StandingViewState>!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        setupChildViewControllers()
        observeViewStore()

        viewStore.send(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isMovingToParent {
            viewStore.send(.selectTeam(nil))
        }
    }
}

// MARK: - Setup

extension CompetitionStandingViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true

        // Layout
        view.addSubview(standingTableView)
        view.addSubview(loadingIndicator)

        standingTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        standingTableView.register(StandingViewCell.self, forCellReuseIdentifier: StandingViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<CompetitionStandingView.ViewState.Section, StandingViewState>(tableView: standingTableView) { [weak self] tableView, indexPath, itemState in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StandingViewCell.identifier, for: indexPath) as? StandingViewCell else {
                fatalError("Failed to dequeue cell of `StandingViewCell`")
            }

            cell.store = self?.store
                .scope(
                    state: { _ in itemState },
                    action: {
                        CompetitionStandingView.Action.standingAction(id: itemState.id, action: $0)
                    }
                )

            return cell
        }

        dataSource.defaultRowAnimation = .fade
    }

    private func setupChildViewControllers() {
        store.scope(
            state: \.selectedTeam,
            action: {
                CompetitionStandingView.Action.teamAction($0)
            })
            .ifLet { [weak self] store in
                let teamViewController = TeamViewController(store: store)
                self?.navigationController?.pushViewController(teamViewController, animated: true)
            } else: { [weak self] in
                if let _ = self?.navigationController?.topViewController as? TeamViewController {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Observe ViewStore

extension CompetitionStandingViewController {
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
            .leagueName
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellables)

        viewStore.publisher
            .standings
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)
    }
}
