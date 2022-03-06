//
//  SectionHeaderView.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 05/03/2022.
//

import SnapKit
import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SectionHeaderView"

    // MARK: - Subviews

    lazy var titleLabel = UILabel().apply {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .left
    }

    lazy var actionButton = UIButton(type: .system).apply {
        $0.titleLabel?.font = .systemFont(ofSize: 16)
        $0.setTitleColor(.systemBlue, for: .normal)
    }

    // MARK: - Life cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SectionHeaderView {
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            actionButton
        ]).apply {
            $0.axis = .horizontal
            $0.spacing = 16
        }

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }

        actionButton.snp.contentHuggingHorizontalPriority = UILayoutPriority.defaultHigh.rawValue + 1
        actionButton.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultLow.rawValue + 1
    }
}
