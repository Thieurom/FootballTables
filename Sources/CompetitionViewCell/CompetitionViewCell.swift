//
//  CompetitionViewCell.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import CommonExtensions
import ComposableArchitecture
import ComposableExtensions
import SDWebImage
import SnapKit
import Theme
import UIKit

public class CompetitionViewCell: StoreTableViewCell<CompetitionViewState, CompetitionViewCell.Action> {
    public static let identifier = "CompetitionViewCell"

    // MARK: - Core

    public enum Action {
        case selected
    }

    public static let reducer = Reducer<CompetitionViewState, Action, Void> { state, action, _ in
        switch action {
        case .selected:
            return .none
        }
    }

    // MARK: - Subviews

    public lazy var nameLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .black
        $0.textAlignment = .left
    }

    public lazy var logoImageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.theme.cgColor
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

    public override func observeViewStore() {
        guard let viewStore = viewStore else {
            return
        }

        viewStore.publisher
            .competitionLogoUrl
            .compactMap { $0 }
            .sink { [weak self] in
                self?.logoImageView.sd_setImage(with: $0)
            }
            .store(in: &cancellables)

        viewStore.publisher
            .competitionName
            .map(Optional.some)
            .assign(to: \.text, on: nameLabel)
            .store(in: &cancellables)

        tapGesture.addTarget(self, action: #selector(CompetitionViewCell.cellDidTap))
    }
}

extension CompetitionViewCell {
    private func setupViews() {
        selectionStyle = .none

        let stackView = UIStackView(arrangedSubviews: [
            logoImageView,
            nameLabel
        ]).apply {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .center
        }

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-16)
        }

        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        logoImageView.layer.cornerRadius = 16

        logoImageView.snp.contentHuggingHorizontalPriority = UILayoutPriority.defaultHigh.rawValue + 1
        logoImageView.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultLow.rawValue + 1

        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func cellDidTap() {
        if let viewStore = viewStore {
            viewStore.send(.selected)
        }
    }
}
