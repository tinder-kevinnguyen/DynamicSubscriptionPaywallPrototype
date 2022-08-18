//
//  DynamicSubscriptionPaywallViewController.swift
//  TapStore
//
//  Created by Paul Hudson on 01/10/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

typealias SubscriptionDataSource = UICollectionViewDiffableDataSource<SubscriptionSection, Item>
typealias SubscriptionSnapshot = NSDiffableDataSourceSnapshot<SubscriptionSection, Item>

struct Product: Hashable {
    let skuID: String
    let tag: String?
    let amount: String?
    let pricePerUnit: String?
    let totalPrice: String?
    let savings: String?
    let image: String
}

struct Feature: Hashable {
    let title: String
    let subtitle: String?
    let image: String
}

enum Item: Hashable {
    case product(Product)
    case feature(Feature)

    static func == (lhs: Item, rhs: Item) -> Bool {
        switch (lhs, rhs) {
        case let (.product(lhsItem), .product(rhsItem)):
            return lhsItem == rhsItem
        case let (.feature(lhsItem), .feature(rhsItem)):
            return lhsItem == rhsItem
        default:
            return false
        }
    }
}

struct SubscriptionSection: Hashable {
    let items: [Item]
    let type: SectionEnum
}

enum SectionEnum: String {
    case products = "Select a plan"
    case features = "Included with Tinder Gold"
}

final class DynamicSubscriptionPaywallViewController: UIViewController {
    let sections = createSections()
    var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<SubscriptionSection, Item>?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)

        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseIdentifier)
        collectionView.register(FeatureCell.self, forCellWithReuseIdentifier: FeatureCell.reuseIdentifier)
        collectionView.register(SectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SectionFooter.reuseIdentifier)

        makeDataSource()
        reloadData()
    }

    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with item: Item, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: item)
        return cell
    }

    // MARK: - DiffableDataSource

    private static func createSections() -> [SubscriptionSection] {
        let productItems: [Item] = [
            .product(Product(skuID: "1", tag: "Best Value", amount: "12 Months", pricePerUnit: "$8.33/mo", totalPrice: "$99.99 total", savings: "Save 67%", image: "Heading1")),
            .product(Product(skuID: "2", tag: "Popular", amount: "6 Months", pricePerUnit: "$12.50/mo", totalPrice: "$79.99 total", savings: "Save 50%", image: "Heading2")),
            .product(Product(skuID: "3", tag: nil, amount: "1 Month", pricePerUnit: "$24.99/mo", totalPrice: "$24.99 total", savings: nil, image: "Heading3"))
        ]
        let featureItems: [Item] = [
            .feature(Feature(title: "See Who Likes You", subtitle: nil, image: "iOS1")),
            .feature(Feature(title: "Top Picks", subtitle: "Swipe on curated profiles, everyday.", image: "iOS2")),
            .feature(Feature(title: "Unlimited Likes", subtitle: nil, image: "iOS3")),
            .feature(Feature(title: "1 Free Boost Each Month", subtitle: nil, image: "iOS4")),
            .feature(Feature(title: "Control Your Age & Distance", subtitle: nil, image: "iOS5")),
            .feature(Feature(title: "Control Who Sees You", subtitle: "Only be shown to certain types of people on Tinder.", image: "iOS6")),
            .feature(Feature(title: "Swipe All Around the World", subtitle: nil, image: "iOS7")),
            .feature(Feature(title: "5 Free Super Likes a Day", subtitle: nil, image: "iOS8")),
            .feature(Feature(title: "Unlimited Rewinds", subtitle: nil, image: "iOS9")),
            .feature(Feature(title: "Hide Ads", subtitle: nil, image: "iOS10")),
        ]
        return [SubscriptionSection(items: productItems, type: .products),
                SubscriptionSection(items: featureItems, type: .features)]
    }

    private func makeDataSource() {
        dataSource
            = SubscriptionDataSource(collectionView: collectionView) { [weak self] _, indexPath, item -> UICollectionViewCell? in
                guard let self = self else { return nil }

                switch self.sections[indexPath.section].type {
                case .features:
                    return self.configure(FeatureCell.self, with: item, for: indexPath)
                default:
                    return self.configure(CarouselCell.self, with: item, for: indexPath)
                }
            }

        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseIdentifier, for: indexPath) as? SectionHeader else {
                    return nil
                }

                guard let firstApp = self?.dataSource?.itemIdentifier(for: indexPath) else { return nil }
                guard let section = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstApp) else { return nil }

                sectionHeader.title.text = section.type.rawValue
                return sectionHeader

            } else {
                guard let sectionFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionFooter.reuseIdentifier, for: indexPath) as? SectionFooter else {
                    return nil
                }
                return sectionFooter
            }
        }
    }

    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SubscriptionSection, Item>()
        snapshot.appendSections(sections)

        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }

        dataSource?.apply(snapshot)
    }

    // MARK: - CV Compositional Layout

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.sections[sectionIndex]

            switch section.type {
            case .products:
                return self.createCarouselSection()
            case .features:
                let listSection = self.createListSection()
                let decoration = NSCollectionLayoutDecorationItem.background(elementKind: ListBackgroundDecorationView.elementKind)
                decoration.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                listSection.decorationItems = [decoration]
                return listSection
            }
        }

        layout.register(
            ListBackgroundDecorationView.self,
            forDecorationViewOfKind: ListBackgroundDecorationView.elementKind)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }

    func createCarouselSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.70), heightDimension: .absolute(194))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        section.orthogonalScrollingBehavior = .groupPaging // comment out and set group size width dimension to 1.0 for 1 item layout

        let header = createSectionHeader()
        let footer = createSectionFooter()
        section.boundarySupplementaryItems = [header, footer]

        return section
    }

    func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .fractionalWidth(0.55))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]

        return section
    }

    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return header
    }

    func createSectionFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(40))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        return footer
    }
}

// MARK: - UICollectionViewDelegate

extension DynamicSubscriptionPaywallViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}
