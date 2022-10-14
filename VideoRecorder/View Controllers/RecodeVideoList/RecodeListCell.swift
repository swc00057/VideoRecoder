//
//  RecodeListCell.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/11.
//

import UIKit
import Photos

final class RecodeListCell: UITableViewCell {

    // MARK: Constant

    static let reuseIdentifier = String(describing: RecodeListCell.self)

    private enum Metrics {
        static let spacing: CGFloat = 8
        static let labelInset: UIEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        static let cornerRadius: CGFloat = 5
    }

    private enum Font {
        static let durationLabel: UIFont = .preferredFont(forTextStyle: .caption1)
        static let titleLabel: UIFont = .preferredFont(forTextStyle: .headline)
        static let dateLabel: UIFont = .preferredFont(forTextStyle: .subheadline)
    }

    // MARK: UI

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .bottom // TODO: 두 열 중 길이가 짧은 열의 아래쪽으로 새로운 영상을 배치합니다.
        stackView.spacing = Metrics.spacing
        return stackView
    }()

    private let durationLabel: UILabel = {
        let inset = Metrics.labelInset
        let label = PaddingLabel(padding: inset)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.durationLabel
        label.textColor = .systemBackground
        label.backgroundColor = .label.withAlphaComponent(0.5)
        label.adjustsFontForContentSizeCategory = true
        label.layer.masksToBounds = true
        label.layer.cornerRadius = Metrics.cornerRadius
        return label
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Metrics.spacing
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.titleLabel
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.dateLabel
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        return label
    }()

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metrics.cornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    // MARK: Properties

    private(set) var representedAssetIdentifier: String!

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupViews() {
        contentView.addSubview(containerStackView)
        contentView.addSubview(durationLabel)

        containerStackView.addArrangedSubview(thumbnailImageView)
        containerStackView.addArrangedSubview(labelStackView)

        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(dateLabel)

        let containerViewInset: CGFloat = 20
        let durationLabelInset: CGFloat = 4
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerViewInset),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerViewInset),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerViewInset),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -containerViewInset),

            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.75),

            durationLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: durationLabelInset),
            durationLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -durationLabelInset),
        ])

        accessoryType = .disclosureIndicator
    }

    func configure(with asset: PHAsset) {
        representedAssetIdentifier = asset.localIdentifier

        titleLabel.text = asset.originalFilename
        durationLabel.text = asset.duration.displayTime
        dateLabel.text = asset.creationDate?.string()
    }

}
