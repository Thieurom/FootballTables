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

    lazy var errorView = MessageView().apply {
        $0.titleLabel.textColor = .gray
        $0.imageView.tintColor = .gray
    }

    lazy var retryButton = UIButton(type: .system)
        .apply(UIButton.roundedButtonStyle)

    // MARK: - DataSource

    private var dataSource: UITableViewDiffableDataSource<TeamView.ViewState.Section, TeamView.ViewState.SectionItem>!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        observeViewStore()

        viewStore.send(.fetchMatches)
    }
}

// MARK: - Setup

extension TeamViewController {
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        [matchesTableView, loadingIndicator, errorView, retryButton]
            .forEach(view.addSubview)

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
            .assign(to: \.isHidden, on: matchesTableView)
            .store(in: &cancellables)

        //
        retryButton.addAction( .init { [weak self] _ in
            self?.viewStore.send(.fetchMatches)
        }, for: .touchUpInside)
    }
}
