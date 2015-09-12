//
//  WalletCellFactory.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/12/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

struct WalletCellFactory {
    //TODO: remove hardcoded data
    
    func modelsForItem(shopItem: ShopItem) -> [TableViewCellModel] {
        switch shopItem.walletType {
        case .Inventory:
            return [
                ComapctBadgeFeedTableCellModel (
                    itemType: FeedItem.ItemType.Item,
                    objectID: "jhjhgjhg",
                    title: shopItem.feedItem.name,
                    details: shopItem.feedItem.author?.title,
                    info: map(NSDate()) {dateFormatter.stringFromDate($0)},
                    imageURL: shopItem.feedItem.image,
                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
                    data: nil
                ),
            ]
            
        case .Sold:
            return [
                ComapctBadgeFeedTableCellModel (
                    itemType: FeedItem.ItemType.Item,
                    objectID: "jhjhgjhg",
                    title: shopItem.feedItem.name,
                    details: shopItem.feedItem.author?.title,
                    info: map(NSDate()) {dateFormatter.stringFromDate($0)},
                    imageURL: shopItem.feedItem.image,
                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
                    data: nil
                ),
            ]
        case .Purchased:
            return [
                ComapctBadgeFeedTableCellModel (
                    itemType: FeedItem.ItemType.Item,
                    objectID: "jhjhgjhg",
                    title: shopItem.feedItem.name,
                    details: shopItem.feedItem.author?.title,
                    info: map(NSDate()) {dateFormatter.stringFromDate($0)},
                    imageURL: shopItem.feedItem.image,
                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
                    data: nil
                ),
            ]
        
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
    
    
    func detailCellReuseIdForModel(model: TableViewCellModel) -> String {
        return TableViewCell.reuseId()
    }
    
    func detailedCellsReuseId() -> [String]  {
        return [ProductListCell.reuseId()]
    }
    
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
        }()
}