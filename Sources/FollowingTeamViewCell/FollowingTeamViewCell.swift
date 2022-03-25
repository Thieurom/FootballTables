//
//  FollowingTeamViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 14/03/2022.
//

import CommonExtensions
import ComposableArchitecture
import ComposableExtensions
import SnapKit
import SDWebImage
import UIKit

public class FollowingTeamViewCell: StoreTableViewCell<FollowingTeamViewState, FollowingTeamViewCell.Action> {
    public static let identifier = "FollowingTeamViewCell"

    public enum Action {
        case selected
    }

    public static let reducer = Reducer<FollowingTeamViewState, Action, Void> { _, action, _ in
        switch action {
        case .selected:
            return .none
        }
    }

    // MARK: - Subviews

    public lazy var teamLogoView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    public lazy var teamNameLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .left
    }

    private lazy var disclosureImagView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.darkGray)
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
            .logoUrl
            .compactMap { $0 }
            .sink { [weak self] in
                self?.teamLogoView.sd_setImage(with: $0)
            }
            .store(in: &cancellables)

        tapGesture.addTarget(self, action: #selector(FollowingTeamViewCell.cellDidTap))
    }
}

// MARK: - Setup

extension FollowingTeamViewCell {
    private func setupViews() {
        selectionStyle = .none

        let stackView = UIStackView(
            arrangedSubviews: [
                teamLogoView,
                teamNameLabel,
                disclosureImagView
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
