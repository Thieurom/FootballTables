//
//  StandingDashboardViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 28/02/2022.
//

import CombineExt
import ComposableArchitecture
import SnapKit
import UIKit

class StandingDashboardViewController: StoreViewController<StandingDashboardView.State, StandingDashboardView.ViewState, StandingDashboardView.Action> {

    // MARK: - Views

    lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    lazy var standingTableView = UITableView(frame: .zero, style: .insetGrouped).apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<StandingDashboardView.ViewState.Section, TeamStandingViewState>!

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
            viewStore.send(.selectCompetitionStanding(nil))
        }
    }
}

// MARK: - Setup

extension StandingDashboardViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .theme
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

        standingTableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        standingTableView.register(TeamStandingViewCell.self, forCellReuseIdentifier: TeamStandingViewCell.identifier)
        standingTableView.delegate = self
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<StandingDashboardView.ViewState.Section, TeamStandingViewState>(tableView: standingTableView) { [weak self] tableView, indexPath, itemState in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamStandingViewCell.identifier, for: indexPath) as? TeamStandingViewCell else {
                fatalError("Failed to dequeue cell of `TeamStandingViewCell`")
            }

            cell.store = self?.store
                .scope(
                    state: { _ in itemState },
                    action: {
                        StandingDashboardView.Action.teamStandingAction(id: itemState.id, action: $0)
                    }
                )

            return cell
        }

        dataSource.defaultRowAnimation = .fade
    }

    private func setupChildViewControllers() {
        store.scope(
            state: \.selectedCompetitionStanding,
            action: {
                StandingDashboardView.Action.competitionStandingAction($0)
            })
            .ifLet { [weak self] store in
                let competitionStandingViewController = CompetitionStandingViewController(store: store)
                self?.navigationController?.pushViewController(competitionStandingViewController, animated: true)
            } else: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate

extension StandingDashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: SectionHeaderView.identifier)

        // No reactive here!
        let viewSection = viewStore.sections[section]
        headerView.titleLabel.text = viewSection.header
        headerView.actionButton.setTitle(viewSection.subtitle, for: .normal)

        headerView.actionButton.addAction(UIAction { [weak self] _ in
            self?.viewStore.send(.selectSectionHeader(section))
        }, for: .touchUpInside)

        return headerView
    }
}

// MARK: - Observe ViewStore

extension StandingDashboardViewController {
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
