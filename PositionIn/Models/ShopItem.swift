//
//  ShopItem.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/12/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

struct ShopItem {
    
    var feedItem: FeedItem
    var walletType: WalletType = .Inventory
    
    enum WalletType: Int {
        case Inventory, Sold, Purchased
    }
}