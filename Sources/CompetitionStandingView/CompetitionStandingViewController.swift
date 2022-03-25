//
//  CompetitionStandingViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import ComposableExtensions
import SnapKit
import TeamView
import UIKit

public class CompetitionStandingViewController: StoreViewController<CompetitionStandingView.State, CompetitionStandingView.ViewState, CompetitionStandingView.Action> {

    // MARK: - Views

    public lazy var standingTableView = UITableView().apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<CompetitionStandingView.ViewState.Section, TeamStandingViewState>!

    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        setupChildViewControllers()
        observeViewStore()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isMovingToParent {
            viewStore.send(.selectTeamStanding(nil))
        }
    }
}

// MARK: - Setup

extension CompetitionStandingViewController {
    private func setupViews() {
        // Style
        // `white` isn't clearly showing the separation between table view's sections,
        // but keep it for now.
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        // Layout
        view.addSubview(standingTableView)

        standingTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        standingTableView.register(TeamStandingViewCell.self, forCellReuseIdentifier: TeamStandingViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<CompetitionStandingView.ViewState.Section, TeamStandingViewState>(tableView: standingTableView) { [weak self] tableView, indexPath, itemState in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamStandingViewCell.identifier, for: indexPath) as? TeamStandingViewCell else {
                fatalError("Failed to dequeue cell of `TeamStandingViewCell`")
            }

            cell.store = self?.store
                .scope(
                    state: { _ in itemState },
                    action: {
                        CompetitionStandingView.Action.standingAction(
                            id: itemState.id,
                            action: $0
                        )
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
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Observe ViewStore

extension CompetitionStandingViewController {
    private func observeViewStore() {
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
