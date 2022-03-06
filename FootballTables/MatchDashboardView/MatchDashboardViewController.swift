//
//  MatchDashboardViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CombineExt
import ComposableArchitecture
import SnapKit
import UIKit

class MatchDashboardViewController: StoreViewController<MatchDashboardView.State, MatchDashboardView.ViewState, MatchDashboardView.Action> {

    // MARK: - Views

    lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    lazy var dashboardTableView = UITableView(frame: .zero, style: .insetGrouped).apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<MatchDashboardView.ViewState.Section, MatchDashboardView.ViewState.SectionItem>!

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
            viewStore.send(.selectCompetition(nil))
        }
    }
}

// MARK: - Setup

extension MatchDashboardViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .theme
        navigationController?.navigationBar.prefersLargeTitles = true

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

        dashboardTableView.register(CompetitionViewCell.self, forCellReuseIdentifier: CompetitionViewCell.identifier)
        dashboardTableView.register(MatchViewCell.self, forCellReuseIdentifier: MatchViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<MatchDashboardView.ViewState.Section, MatchDashboardView.ViewState.SectionItem>(tableView: dashboardTableView) { [weak self] tableView, indexPath, sectionItem in
            switch sectionItem {
            case .competition(let competition):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CompetitionViewCell.identifier, for: indexPath) as? CompetitionViewCell else {
                    fatalError("Failed to dequeue cell of `CompetitionViewCell`")
                }

                cell.store = self?.store
                    .scope(
                        state: { _ in competition },
                        action: {
                            MatchDashboardView.Action.competitionAction(
                                id: competition.id,
                                action: $0
                            )
                        }
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
                            MatchDashboardView.Action.matchAction(
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

    private func setupChildViewControllers() {
        store.scope(
            state: \.selectedCompetitionMatch,
            action: {
                MatchDashboardView.Action.competitionMatchAction($0)
            })
            .ifLet { [weak self] store in
                let competitionMatchController = CompetitionMatchViewController(store: store)
                self?.navigationController?.pushViewController(competitionMatchController, animated: true)
            } else: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Observe ViewStore

extension MatchDashboardViewController {
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
            .sections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)
    }
}
