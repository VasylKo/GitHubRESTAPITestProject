//
//  BrowseListCellsProvider.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/21/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import UIKit
import PosInCore

struct FeedItemCellModelFactory {
    //TODO: remove hardcoded data
    
    func compactModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        switch feedItem.type {
        case .Event:
            return [
                CompactFeedTableCellModel(
                    item: feedItem,
                    title: "Art Gallery",
                    details: dateFormatter.stringFromDate(NSDate()),
                    info: "45 People are attending",
                    imageURL: NSURL(string: "https://cdn4.iconfinder.com/data/icons/Pretty_office_icon_part_2/256/add-event.png")
                ),
            ]

        case .Promotion:
            return [
                CompactFeedTableCellModel(
                    item: feedItem,
                    title: "Arts & Crafts Summer Sale",
                    details: "The Sydney Art Store",
                    info: "Save 80%",
                    imageURL: NSURL(string: "http://2.bp.blogspot.com/-A8Yu--RWxYg/UxH1ZD-ZBuI/AAAAAAAAPkk/ZoP_JtpeKR4/s1600/promo.gif")
                ),
            ]
        case .Item:
            return [
                ComapctPriceFeedTableCellModel (
                    item: feedItem,
                    title: "The forest",
                    details: "Edwarn Ryan",
                    info: "0.09 miles",
                    imageURL: NSURL(string: "http://2.bp.blogspot.com/-A8Yu--RWxYg/UxH1ZD-ZBuI/AAAAAAAAPkk/ZoP_JtpeKR4/s1600/promo.gif"),
                    price: 99.8
                ),
            ]
        case .Post:
            return [
                CompactFeedTableCellModel(
                    item: feedItem,
                    title: "Betty Wheeler",
                    details: "Lovely day to go golfing",
                    info: "",
                    imageURL: NSURL(string: "http://2.bp.blogspot.com/-A8Yu--RWxYg/UxH1ZD-ZBuI/AAAAAAAAPkk/ZoP_JtpeKR4/s1600/promo.gif")
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