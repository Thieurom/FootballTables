//
//  TeamStandingViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 27/02/2022.
//

import ComposableArchitecture
import ComposableExtensions
import SnapKit
import UIKit

public class TeamStandingViewCell: StoreTableViewCell<TeamStandingViewState, TeamStandingViewCell.Action> {
    public static let identifier = "TeamStandingViewCell"

    public enum Action {
        case selected
    }

    public static let reducer = Reducer<TeamStandingViewState, Action, Void> { state, action, _ in
        switch action {
        case .selected:
            return .none
        }
    }

    // MARK: - Subviews

    public lazy var positionLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .gray
        $0.textAlignment = .right
    }

    public lazy var teamLogoView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    public lazy var teamNameLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .left
    }

    public lazy var pointsLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .gray
        $0.textAlignment = .right
    }

    private lazy var tapGesture = UITapGestureRecognizer()

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
            .name
            .map(Optional.some)
            .assign(to: \.text, on: teamNameLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .position
            .map(Optional.some)
            .assign(to: \.text, on: positionLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .points
            .map(Optional.some)
            .assign(to: \.text, on: pointsLabel)
            .store(in: &cancellables)

        viewStore.publisher
            .logoUrl
            .compactMap { $0 }
            .sink { [weak self] in
                self?.teamLogoView.sd_setImage(with: $0)
            }
            .store(in: &cancellables)

        tapGesture.addTarget(self, action: #selector(TeamStandingViewCell.cellDidTap))
    }
}

// MARK: - Setup

extension TeamStandingViewCell {
    private func setupViews() {
        let stackView = UIStackView(
            arrangedSubviews: [
                positionLabel,
                teamLogoView,
                teamNameLabel,
                pointsLabel
            ]
        ).apply {
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = .init(
                top: 8, leading: 16, bottom: 8, trailing: 24
            )

            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .center
        }

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        positionLabel.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        teamLogoView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        teamNameLabel.snp.contentHuggingHorizontalPriority = UILayoutPriority.defaultLow.rawValue - 1
        teamNameLabel.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultHigh.rawValue - 1

        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func cellDidTap() {
        if let viewStore = viewStore {
            viewStore.send(.selected)
        }
    }
}
