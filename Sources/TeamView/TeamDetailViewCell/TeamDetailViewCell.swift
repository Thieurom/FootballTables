//
//  TeamDetailViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import CommonUI
import ComposableArchitecture
import ComposableExtensions
import SDWebImage
import SnapKit
import UIKit

public class TeamDetailViewCell: StoreTableViewCell<TeamDetailViewState, TeamDetailViewCell.Action> {
    public static let identifier = "TeamDetailViewCell"

    // MARK: - Core

    public enum Action {
        case followButtonTapped
    }

    public static let reducer = Reducer<TeamDetailViewState, Action, Void> { _, action, _ in
        switch action {
        case .followButtonTapped:
            return .none
        }
    }

    // MARK: - Subviews

    public lazy var teamLogoView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    public lazy var teamNameLabel = UILabel().apply {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
    }

    public lazy var competitionLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.minimumScaleFactor = 0.75
    }

    public lazy var followButton = UIButton()
        .apply(UIButton.roundedButtonStyle)

    // MARK: - Life cycle

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Observe ViewStore

    public override func observeViewStore() {
        guard let viewStore = viewStore else {
            return
        }

        viewStore.publisher
            .teamLogoUrl
            .compactMap { $0 }
            .sink { [weak self] in
                self?.teamLogoView.sd_setImage(with: $0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .teamName
            .map(Optional.some)
            .assign(to: \.text, on: teamNameLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .competitionName
            .map(Optional.some)
            .assign(to: \.text, on: competitionLabel)
            .store(in: &cancellables)
        
        viewStore.publisher
            .followingStatusTitle
            .sink { [weak self] in
                self?.followButton.setTitle($0, for: .normal)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .isFollowing
            .map { $0 ? UIButton.primaryButtonStyle : UIButton.secondaryButtonStyle }
            .sink { [weak self] in
                self?.followButton.apply($0)
            }
            .store(in: &cancellables)

        followButton.addTarget(self, action: #selector(TeamDetailViewCell.followButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Private

extension TeamDetailViewCell {
    private func setupViews() {
        selectionStyle = .none

        [teamLogoView, teamNameLabel, competitionLabel, followButton]
            .forEach(contentView.addSubview)

        teamLogoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(110)
            make.height.equalTo(110)
            make.centerX.equalToSuperview()
        }

        teamNameLabel.snp.makeConstraints { make in
            make.top.equalTo(teamLogoView.snp.bottom).offset(12)
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
            make.centerX.equalToSuperview()
        }

        competitionLabel.snp.makeConstraints { make in
            make.top.equalTo(teamNameLabel.snp.bottom)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(competitionLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-24)
        }

        competitionLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue - 1
        competitionLabel.snp.contentCompressionResistanceVerticalPriority = UILayoutPriority.defaultHigh.rawValue - 1
    }
    
    @objc private func followButtonDidTap() {
        if let viewStore = viewStore {
            viewStore.send(.followButtonTapped)
        }
    }
}
