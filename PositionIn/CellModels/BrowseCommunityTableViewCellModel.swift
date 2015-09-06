//
//  BrowseCommunityTableViewCellModel.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class BrowseCommunityTableViewCellModel: TableViewCellModel {
    let objectId: CRUDObjectId
    let tapAction: BrowseCommunityViewController.Action
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action) {
        self.objectId = objectId
        self.tapAction = tapAction
    }
}

final class BrowseCommunityHeaderCellModel: BrowseCommunityTableViewCellModel {
    let title: String
    let url: NSURL?
    
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action, title: String, url: NSURL?) {
        self.title = title
        self.url = url
        super.init(objectId: objectId, tapAction: tapAction)
    }
}

final class BrowseCommunityInfoCellModel: BrowseCommunityTableViewCellModel {
    let membersCount: Int?
    let text: String?
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action, members: Int?, text: String?) {
        self.text = text
        membersCount = members
        super.init(objectId: objectId, tapAction: tapAction)
    }
}

final class BrowseCommunityActionCellModel: BrowseCommunityTableViewCellModel {
    let actions: [BrowseCommunityViewController.Action]
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action, actions: [BrowseCommunityViewController.Action]) {
        self.actions = actions
        super.init(objectId: objectId, tapAction: tapAction)
    }
}