//
//  CompetitionMatchViewController.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 02/03/2022.
//

import CombineExt
import CommonUI
import ComposableArchitecture
import ComposableExtensions
import MatchViewCell
import SnapKit
import UIKit

public class CompetitionMatchViewController: StoreViewController<CompetitionMatchView.State, CompetitionMatchView.ViewState, CompetitionMatchView.Action> {

    // MARK: - Views

    public lazy var loadingIndicator = UIActivityIndicatorView().apply {
        $0.hidesWhenStopped = true
    }

    public lazy var dashboardTableView = UITableView().apply {
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

    private var dataSource: UITableViewDiffableDataSource<CompetitionMatchView.ViewState.Section, MatchViewState>!

    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDataSource()
        observeViewStore()

        viewStore.send(.fetchMatches)
    }
}

// MARK: - Setup

extension CompetitionMatchViewController {
    private func setupViews() {
        // Style
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

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

        dashboardTableView.register(MatchViewCell.self, forCellReuseIdentifier: MatchViewCell.identifier)

        retryButton.addTarget(self, action: #selector(CompetitionMatchViewController.retryButtonDidTap), for: .touchUpInside)
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

    @objc private func retryButtonDidTap() {
        viewStore.send(.fetchMatches)
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
            .matchSections
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
