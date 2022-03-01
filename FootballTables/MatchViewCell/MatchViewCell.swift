//
//  MatchViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 01/03/2022.
//

import ComposableArchitecture
import SnapKit
import UIKit

class MatchViewCell: StoreTableViewCell<MatchViewState, Never> {
    static let identifier = "MatchViewCell"

    // MARK: - Subviews

    lazy var matchDayLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }

    lazy var homeTeamNameLabel = UILabel().apply {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    lazy var awayTeamNameLabel = UILabel().apply {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    lazy var scoreLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
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

    override func observeViewStore() {
        guard let viewStore = viewStore else {
            return
        }

        viewStore.publisher
            .matchDay
            .map(Optional.some)
            .assign(to: \.text, on: matchDayLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .homeTeam
            .map(Optional.some)
            .assign(to: \.text, on: homeTeamNameLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .awayTeam
            .map(Optional.some)
            .assign(to: \.text, on: awayTeamNameLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .score
            .map(Optional.some)
            .assign(to: \.text, on: scoreLabel)
            .store(in: &cancellables)
    }
}

extension MatchViewCell {
    private func setupViews() {
        selectionStyle = .none

        let stackView = UIStackView(
            arrangedSubviews: [
                homeTeamNameLabel,
                scoreLabel,
                awayTeamNameLabel
            ]
        )

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(
            top: 8, leading: 16, bottom: 8, trailing: 16
        )

        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        contentView.addSubview(matchDayLabel)
        contentView.addSubview(stackView)

        matchDayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(matchDayLabel).offset(16)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        scoreLabel.snp.makeConstraints { make in
            make.width.equalTo(60)
        }

        homeTeamNameLabel.snp.makeConstraints { make in
            make.width.equalTo(awayTeamNameLabel)
        }
    }
}
