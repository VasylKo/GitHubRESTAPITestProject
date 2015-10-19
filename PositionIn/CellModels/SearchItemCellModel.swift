//
//  SearchSectionCellModel.swift
//  PositionIn
//
//  Created by mpol on 10/5/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

protocol SearchTableCellModel: TableViewCellModel {
}

final class SearchSectionCellModel: SearchTableCellModel {
    let itemType: FeedItem.ItemType
    let title: String?
    var isTappable: Bool = false
    
    init(itemType: FeedItem.ItemType, title: String?, isTappable: Bool) {
        self.title = title
        self.isTappable = isTappable
        self.itemType = itemType
    }
}

final class SearchItemCellModel: SearchTableCellModel {
    let objectID: CRUDObjectId
    let title: String?
    let searchString: String?
    let subtitle: String?
    let localImageName: String?
    let remoteImageURL: NSURL?
    let itemType: SearchItem.SearchItemType
    
    init(itemType: SearchItem.SearchItemType, objectID: CRUDObjectId, title: String?,
        searchString: String?, subtitle: String?, localImageName: String?, remoteImageURL: NSURL?) {
        self.objectID = objectID
        self.title = title
        self.searchString = searchString
        self.subtitle = subtitle
        self.itemType = itemType
        self.localImageName = localImageName
        self.remoteImageURL = remoteImageURL
    }
}
