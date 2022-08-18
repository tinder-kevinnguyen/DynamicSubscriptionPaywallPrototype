//
//  ListBackgroundDecorationView.swift
//  DynamicSubscriptionPaywall
//
//  Created by Kevin Nguyen on 8/17/22.
//  Copyright © 2022 Hacking with Swift. All rights reserved.
//

import UIKit

class ListBackgroundDecorationView: UICollectionReusableView {

    static let elementKind = "list-background-element-kind"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}
