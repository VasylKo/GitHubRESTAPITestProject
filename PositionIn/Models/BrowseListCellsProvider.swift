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

class BrowseListCellsProvider: NSObject {
    
    class func reuseIdFor(#feedItem: FeedItem) -> String {
        switch feedItem.type {
        case .Promotions:
            return PromotionListCell.reuseId()
        case .Event:
            return EventListCell.reuseId()
        case .Post:
            return PostListCell.reuseId()
        case .Item:
            return ProductListCell.reuseId()
        default:
            return ProductListCell.reuseId()
        }
    }
    
    class func modelFor(#feedItem: FeedItem) -> TableViewCellModel {
        switch feedItem.type {
        case .Promotions:
            return TableViewCellTitleImageAuthorDiscountModel(title: "Arts & Crafts Summer Sale", author: "The Sydney Art Store", discount: "Save 80%", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            
        case .Event:
            return TableViewCellTitleImageDateInfoModel(title: "Art Gallery", date: NSDate(), info: "45 People are attending", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            
        case .Post:
            return TableViewCellTitleImageInfoModel(title: "Betty Wheeler", info: "Lovely day to go golfing", imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png")
            
        case .Item:
            return TableViewCellTitleImagePriceDistanceModel(title: "The forest", owner: "Edwarn Ryan", distance: 0.09, imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png", price: 99.8)
            
        default:
            return TableViewCellTitleImagePriceDistanceModel(title: "The forest", owner: "Edwarn Ryan", distance: 0.09, imageURL: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png", price: 99.8)
        }
    }
}