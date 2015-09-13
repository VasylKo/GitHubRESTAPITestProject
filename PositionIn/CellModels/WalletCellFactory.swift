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
        default :
            return [
                ComapctBadgeFeedTableCellModel (
                    itemType: FeedItem.ItemType.Item,
                    objectID: "jhjhgjhg",
                    title: shopItem.feedItem.name,
                    details: shopItem.feedItem.details,
                    info: shopItem.feedItem.text,
                    imageURL: shopItem.feedItem.image,
                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
                    data: nil
                ),
            ]
//            
//        case .Sold:
//            return [
//                ComapctBadgeFeedTableCellModel (
//                    itemType: FeedItem.ItemType.Item,
//                    objectID: "jhjhgjhg",
//                    title: shopItem.feedItem.name,
//                    details: shopItem.feedItem.author?.title,
//                    info: map(NSDate()) {dateFormatter.stringFromDate($0)},
//                    imageURL: shopItem.feedItem.image,
//                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
//                    data: nil
//                ),
//            ]
//        case .Purchased:
//            return [
//                ComapctBadgeFeedTableCellModel (
//                    itemType: FeedItem.ItemType.Item,
//                    objectID: "jhjhgjhg",
//                    title: shopItem.feedItem.name,
//                    details: shopItem.feedItem.author?.title,
//                    info: map(NSDate()) {dateFormatter.stringFromDate($0)},
//                    imageURL: shopItem.feedItem.image,
//                    badge: map(shopItem.feedItem.price) { "$\(Int($0))"},
//                    data: nil
//                ),
//            ]
//        
//        default:
//            return []
        }
    }
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
        }()
}