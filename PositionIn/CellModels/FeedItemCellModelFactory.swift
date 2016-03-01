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
    
    func compactModelsForItem(delegate : ActionsDelegate, feedItem: FeedItem) -> [TableViewCellModel] {
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
        case .Emergency:
            fallthrough
        case .Post:
            fallthrough
        case .Project:
            return [
                CompactFeedTableCellModel(delegate:delegate,
                    item: feedItem,
                    title: feedItem.name,
                    details: feedItem.author?.title,
                    info: nil,
                    text: feedItem.text,
                    price: feedItem.donations,
                    imageURL: feedItem.image,
                    avatarURL: feedItem.author?.avatar,
                    location: feedItem.location,
                    numOfLikes: feedItem.numOfLikes,
                    numOfComments: feedItem.numOfComments,
                    date: feedItem.date,
                    data: feedItem.itemData)
            ]
        case .Unknown:
            fallthrough
        default:
            return []
        }
    }
    
    func compactCellReuseIdForModel(model: TableViewCellModel, showCardCells: Bool) -> String {
        if let model = model as? CompactFeedTableCellModel {
            switch model.item.type {
            case .Post:
                fallthrough
            case .News:
                return NewsCardCell.reuseId()
            case .GiveBlood:
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
                fallthrough
            case .Emergency:
                fallthrough
            case .Training:
                return showCardCells ? ExploreCardCell.reuseId() : EventListCell.reuseId()
            default:
                break
            }
        }
        return TableViewCell.reuseId()
    }
    
    func compactCellsReuseId() -> [String]  {
        return [EventListCell.reuseId(), PostListCell.reuseId(), ExploreCardCell.reuseId(), NewsCardCell.reuseId()]
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
        return ExploreCardCell.reuseId()
    }

    func detailedCellsReuseId() -> [String]  {
        return [ExploreCardCell.reuseId(), NewsCardCell.reuseId()]
    }
    
    func walletModelsForItem(feedItem: FeedItem) -> [TableViewCellModel] {
        return [
            ComapctBadgeFeedTableCellModel (
                delegate: nil,
                item: feedItem,
                title: feedItem.name,
                details: feedItem.details,
                info: feedItem.text,
                text: feedItem.text,
                imageURL: feedItem.image,
                avatarURL: nil,
                badge: feedItem.price.map {
                    let newValue = $0 as Float
                    return AppConfiguration().currencyFormatter.stringFromNumber(NSNumber(float: newValue)) ?? ""},
                data: feedItem.itemData
            ),
        ]
    }
    
    func walletReuseIdForModel(model: TableViewCellModel) -> String {
        return EventListCell.reuseId()
    }
    
    func walletReuseId() -> [String]  {
        return [EventListCell.reuseId()]
    }
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter
    }()
}