//
//  MessageView.swift
//  FootballTables
//
//  Created by Doan Le Thieu on 07/03/2022.
//

import CommonExtensions
import SnapKit
import UIKit

public class MessageView: UIView {

    // MARK: - Subviews

    public lazy var imageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
    }

    public lazy var titleLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.lineBreakMode = .byWordWrapping
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension MessageView {
    public func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    public func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}

// MARK: - Private

extension MessageView {
    private func setupViews() {
        [imageView, titleLabel]
            .forEach(addSubview)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.contentHuggingVerticalPriority = UILayoutPriority.defaultLow.rawValue + 1
        titleLabel.snp.contentCompressionResistanceVerticalPriority = UILayoutPriority.defaultHigh.rawValue + 1
    }
}
