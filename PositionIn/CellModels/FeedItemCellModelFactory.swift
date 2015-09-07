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
    //TODO: remove hardcoded data
    
    func compactModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        switch feedItem.type {
        case .Event:
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.text,
                    info: map(feedItem.date) {dateFormatter.stringFromDate($0)},
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
            let discountFormat = NSLocalizedString("Save $%@", comment: "Compact feed: DiscountFormat")
            let discount: Float =  146.0
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: map(feedItem.category) { $0.displayString() },
                    info: map(feedItem.details) { String(format: discountFormat, $0 )} ,
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
                    info: map(feedItem.date) {dateFormatter.stringFromDate($0)},
                    imageURL: feedItem.image,
                    badge: map(feedItem.price) { "$\(Int($0))"},
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
    
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
    }()
}