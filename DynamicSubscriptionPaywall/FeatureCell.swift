//
//  FeatureCell.swift
//  TapStore
//
//  Created by Paul Hudson on 01/10/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class FeatureCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "FeatureCell"

    let name = UILabel()
    let subtitle = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        name.font = UIFont.preferredFont(forTextStyle: .headline)
        name.textColor = .label

        subtitle.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = .secondaryLabel

        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true

        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let innerStackView = UIStackView(arrangedSubviews: [name, subtitle])
        innerStackView.axis = .vertical

        let outerStackView = UIStackView(arrangedSubviews: [imageView, innerStackView])
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        outerStackView.alignment = .center
        outerStackView.spacing = 10
        contentView.addSubview(outerStackView)

        NSLayoutConstraint.activate([
            outerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            outerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            outerStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    func configure(with item: Item) {
        if case .feature(let feature) = item {
            name.text = feature.title
            imageView.image = UIImage(named: feature.image)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Just… no")
    }
}
