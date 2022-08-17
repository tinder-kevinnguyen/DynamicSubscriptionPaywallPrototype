//
//  SectionFooter.swift
//  DynamicSubscriptionPaywall
//
//  Created by Kevin Nguyen on 8/17/22.
//  Copyright © 2022 Hacking with Swift. All rights reserved.
//

import UIKit

class SectionFooter: UICollectionReusableView {
    static let reuseIdentifier = "SectionFooter"

    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .label
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .regular))
        title.numberOfLines = 0
        title.text = "By tapping Continue, you will be charged, your subscription will auto-renew for the same price and package length until you cancel via App Store settings, and you agree to our Terms."
        addSubview(title)

        setUpConstraints()
    }

    func setUpConstraints(){
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.topAnchor.constraint(equalTo: topAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
