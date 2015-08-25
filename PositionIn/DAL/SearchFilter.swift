//
//  SearchFilter.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

struct SearchFilter {
    let name: String?
    let itemTypes: [FeedItem.ItemType]
    let categories: [ItemCategory]
    let startPrice: Double?
    let endPrice: Double?
    let startDate: NSDate?
    let endDate: NSDate?
    let radius: Double?
}