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

    lazy var teamLogoView = UIImageView()

    lazy var teamNameLabel = UILabel().apply {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 28, weight: .black)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.lineBreakMode = .byWordWrapping
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
            .assign(to: \.text, on: teamNameLabel)
            .store(in: &cancellables)
    }
}

// MARK: - Private

extension TeamDetailViewCell {
    private func setupViews() {
        selectionStyle = .none

        [teamLogoView, teamNameLabel]
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
            make.bottom.equalToSuperview().offset(-12)
        }

        teamNameLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue + 1
        teamNameLabel.snp.contentCompressionResistanceVerticalPriority = UILayoutPriority.defaultHigh.rawValue + 1
    }
}
