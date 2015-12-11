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
        case .GiveBlood:
            fallthrough
        case .News:
            fallthrough
        case .Event:
            fallthrough
        case .Project:
            fallthrough
        case .Market:
            fallthrough
        case .BomaHotels:
            fallthrough
        case .Volunteer:
            fallthrough
        case .Training:
            fallthrough
        case .Project:
            return [
                CompactFeedTableCellModel(
                    itemType: feedItem.type,
                    objectID: feedItem.objectId,
                    title: feedItem.name,
                    details: feedItem.author?.title,
                    info: nil,
                    price: feedItem.donations,
                    imageURL: feedItem.image,
                    location: feedItem.location,
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
            case .GiveBlood:
                fallthrough
            case .News:
                fallthrough
            case .Event:
                fallthrough
            case .Market:
                fallthrough
            case .BomaHotels:
                fallthrough
            case .Volunteer:
                fallthrough
            case .Project:
                return ProductListCell.reuseId()
            case .Emergency:
                return EmergencyListCell.reuseId()
            case .Training:
                return TrainingListCell.reuseId()
            default:
                break
            }
        }
        return TableViewCell.reuseId()
    }
    
    func compactCellsReuseId() -> [String]  {
        return [ProductListCell.reuseId(), TrainingListCell.reuseId(), EmergencyListCell.reuseId()]
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
                    return AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""},
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
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
    }()
}