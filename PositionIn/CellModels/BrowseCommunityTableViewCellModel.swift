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
    let showInfo: Bool
    weak var actionConsumer: CommunityFeedActionConsumer?
    
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action, title: String, url: NSURL?, showInfo: Bool) {
        self.title = title
        self.url = url
        self.showInfo = showInfo
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
    weak var actionConsumer: BrowseCommunityActionConsumer?
    init(objectId: CRUDObjectId, tapAction: BrowseCommunityViewController.Action, actions: [BrowseCommunityViewController.Action]) {
        self.actions = actions
        super.init(objectId: objectId, tapAction: tapAction)
    }
}