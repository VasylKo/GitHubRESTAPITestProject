//
//  BrowseListCellsProvider.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

struct FeedItemCellModelFactory {
    
    func compactModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        switch feedItem.type {
        case .Event:
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.text,
                    info: feedItem.date.map {dateFormatter.stringFromDate($0)},
                    imageURL: feedItem.image,
                    data: feedItem.itemData
                ),
            ]
            
        case .Post:
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.text,
                    info: nil,
                    imageURL: feedItem.image,
                    data: feedItem.itemData
                ),
            ]

        case .Promotion:
            let discountFormat = NSLocalizedString("Save %@%%", comment: "Compact feed: DiscountFormat")
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.category.map { $0.displayString() },
                    info: feedItem.details.map { String(format: discountFormat, $0 )},
                    imageURL: feedItem.image,
                    data: feedItem.itemData
                ),
            ]
        case .Item:
            return [
                ComapctBadgeFeedTableCellModel (
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.author?.title,
                    info: feedItem.date.map {dateFormatter.stringFromDate($0)},
                    imageURL: feedItem.image,
                    badge: feedItem.price.map {
                        let newValue = $0 as Float
                        return currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""},
                    data: feedItem.itemData
                ),
            ]
        case .Unknown:
            fallthrough
        default:
            return []
        }
    }
    
    func compactCellReuseIdForModel(model: TableViewCellModel) -> String {
        if let model = model as? CompactFeedTableCellModel {
            switch model.itemType {
            case .Promotion:
                return PromotionListCell.reuseId()
            case .Event:
                return EventListCell.reuseId()
            case .Post:
                return PostListCell.reuseId()
            case .Item:
                return ProductListCell.reuseId()
            default:
                break
            }
        }
        return TableViewCell.reuseId()
    }
    
    func compactCellsReuseId() -> [String]  {
        return [ProductListCell.reuseId(), EventListCell.reuseId(), PromotionListCell.reuseId(), PostListCell.reuseId()]
    }
    
    func detailedModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        switch feedItem.type {
            //Return expanded cells
        case .Unknown:
            fallthrough
        default:
            return []
        }
    }
    
    func detailCellReuseIdForModel(model: TableViewCellModel) -> String {
        return TableViewCell.reuseId()
    }

    func detailedCellsReuseId() -> [String]  {
        return []
    }
    
    func walletModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        return [
            ComapctBadgeFeedTableCellModel (
                itemType: feedItem.type,
                objectID: feedItem.objectId,
                title: feedItem.name,
                details: feedItem.details,
                info: feedItem.text,
                imageURL: feedItem.image,
                badge: feedItem.price.map {
                    let newValue = $0 as Float
                    return currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""},
                data: feedItem.itemData
            ),
        ]
    }
    
    func walletReuseIdForModel(model: TableViewCellModel) -> String {
        return ProductListCell.reuseId()
    }
    
    func walletReuseId() -> [String]  {
        return [ProductListCell.reuseId()]
    }

    private let currencyFormatter: NSNumberFormatter = {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.currencySymbol = "$"
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.roundingMode = .RoundDown
        return currencyFormatter
        }()
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
    }()
}