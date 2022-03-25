//
//  MatchDashboardViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CombineExt
import CommonExtensions
import CommonUI
import CompetitionMatchView
import CompetitionViewCell
import ComposableArchitecture
import ComposableExtensions
import MatchViewCell
import SnapKit
import UIKit

public class MatchDashboardViewController: StoreViewController<MatchDashboardView.State, MatchDashboardView.ViewState, MatchDashboardView.Action> {

    // MARK: - Views

    public lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    public lazy var dashboardTableView = UITableView(frame: .zero, style: .insetGrouped).apply {
        $0.backgroundColor = .clear
    }

    public lazy var errorView = MessageView().apply {
        $0.titleLabel.textColor = .gray
        $0.imageView.tintColor = .gray
    }

    public lazy var retryButton = UIButton(type: .system)
        .apply(UIButton.roundedButtonStyle)
        .apply(UIButton.secondaryButtonStyle)

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<MatchDashboardView.ViewState.Section, MatchDashboardView.ViewState.SectionItem>!

    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        setupChildViewControllers()
        observeViewStore()

        viewStore.send(.fetchMatches)
    }

    public override func viewDidAppear(_ animated: Bool) {
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
        [dashboardTableView, loadingIndicator, errorView, retryButton]
            .forEach(view.addSubview)

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

        errorView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        retryButton.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.top.equalTo(errorView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }

        dashboardTableView.register(CompetitionViewCell.self, forCellReuseIdentifier: CompetitionViewCell.identifier)
        dashboardTableView.register(MatchViewCell.self, forCellReuseIdentifier: MatchViewCell.identifier)

        retryButton.addTarget(self, action: #selector(MatchDashboardViewController.retryButtonDidTap), for: .touchUpInside)
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
                competitionMatchController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(competitionMatchController, animated: true)
            } else: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancellables)
    }

    @objc private func retryButtonDidTap() {
        viewStore.send(.fetchMatches)
    }
}

// MARK: - Observe ViewStore

extension MatchDashboardViewController {
    private func observeViewStore() {
        //
        viewStore.publisher
            .title
            .map(Optional.some)
            .assign(to: \.title, on: self, ownership: .weak)
            .store(in: &cancellables)

        viewStore.publisher
            .sections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingLoading
            .assign(to: \._isAnimating, on: loadingIndicator)
            .store(in: &cancellables)

        viewStore.publisher
            .errorMessage
            .sink { [weak self] in
                self?.errorView.setTitle($0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .errorSystemImageName
            .compactMap { $0 }
            .map(UIImage.init(systemName:))
            .sink { [weak self] in
                self?.errorView.setImage($0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .retryButtonTitle
            .sink { [weak self] in
                self?.retryButton.setTitle($0, for: .normal)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingError
            .map(!)
            .assign(to: \.isHidden, on: errorView)
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingError
            .map(!)
            .assign(to: \.isHidden, on: retryButton)
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingError
            .assign(to: \.isUserInteractionEnabled, on: retryButton)
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingError
            .assign(to: \.isHidden, on: dashboardTableView)
            .store(in: &cancellables)
    }
}
