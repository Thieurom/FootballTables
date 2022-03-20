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

    lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).apply {
        $0.backgroundColor = .clear
    }

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<MyTeamsDashboardView.ViewState.Section, FollowingTeamViewState>!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        setupChildViewControllers()
        observeViewStore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isMovingToParent {
            viewStore.send(.selectTeam(nil))
        }
    }
}

// MARK: - Setup

extension MyTeamsDashboardViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .theme
        navigationController?.navigationBar.prefersLargeTitles = true

        [tableView, placeholderView]
            .forEach(view.addSubview)

        placeholderView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        tableView.register(FollowingTeamViewCell.self, forCellReuseIdentifier: FollowingTeamViewCell.identifier)
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<MyTeamsDashboardView.ViewState.Section, FollowingTeamViewState>(tableView: tableView) { [weak self] tableView, indexPath, itemState in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowingTeamViewCell.identifier, for: indexPath) as? FollowingTeamViewCell else {
                fatalError("Failed to dequeue cell of `FollowingTeamViewCell`")
            }

            cell.store = self?.store
                .scope(
                    state: { _ in itemState },
                    action: {
                        MyTeamsDashboardView.Action.followingTeamAction(
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
                MyTeamsDashboardView.Action.selectedTeamAction($0)
            })
            .ifLet { [weak self] store in
                let teamViewController = TeamViewController(store: store)
                teamViewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(teamViewController, animated: true)
            } else: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancellables)
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

        viewStore.publisher
            .sections
            .map(\.snapshot)
            .assign(to: \.snapshot, on: dataSource)
            .store(in: &cancellables)

        viewStore.publisher
            .placeholderImageName
            .map(UIImage.init(systemName:))
            .sink { [weak self] in
                self?.placeholderView.setImage($0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .placeholderMessage
            .sink { [weak self] in
                self?.placeholderView.setTitle($0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingPlaceholder
            .map(!)
            .assign(to: \.isHidden, on: placeholderView)
            .store(in: &cancellables)

        viewStore.publisher
            .isShowingPlaceholder
            .assign(to: \.isHidden, on: tableView)
            .store(in: &cancellables)
    }
}
