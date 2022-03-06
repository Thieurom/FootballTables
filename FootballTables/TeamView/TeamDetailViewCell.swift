//
//  TeamDetailViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import SnapKit
import UIKit

class TeamDetailViewCell: StoreTableViewCell<TeamDetailViewState, Never> {
    static let identifier = "TeamDetailViewCell"

    // MARK: - Subviews

    lazy var teamLogoView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    lazy var teamNameLabel = UILabel().apply {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 28, weight: .black)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
    }

    lazy var positionLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.minimumScaleFactor = 0.75
    }

    // MARK: - Life cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Observe ViewStore

    override func observeViewStore() {
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
            .position
            .map(Optional.some)
            .assign(to: \.text, on: positionLabel)
            .store(in: &cancellables)
    }
}

// MARK: - Private

extension TeamDetailViewCell {
    private func setupViews() {
        selectionStyle = .none

        [teamLogoView, teamNameLabel, positionLabel]
            .forEach(contentView.addSubview)

        teamLogoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
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

        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(teamNameLabel.snp.bottom).offset(12)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }

        teamNameLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue + 1
        teamNameLabel.snp.contentCompressionResistanceVerticalPriority = UILayoutPriority.defaultHigh.rawValue + 1
    }
}
