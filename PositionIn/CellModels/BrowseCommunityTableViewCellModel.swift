//
//  BrowseCommunityTableViewCellModel.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class BrowseCommunityTableViewCellModel: TableViewCellModel {
    let community : Community
    let tapAction: BrowseCommunityViewController.Action
    init(community: Community, tapAction: BrowseCommunityViewController.Action) {
        self.community = community
        self.tapAction = tapAction
    }
}

final class BrowseCommunityHeaderCellModel: BrowseCommunityTableViewCellModel {
    let title: String
    let url: NSURL?
    let showInfo: Bool
    let isClosed: Bool?
    weak var actionConsumer: CommunityFeedActionConsumer?
    
    init(community: Community, tapAction: BrowseCommunityViewController.Action, title: String, url: NSURL?, showInfo: Bool, isClosed: Bool?) {
        self.title = title
        self.url = url
        self.showInfo = showInfo
        self.isClosed = isClosed
        super.init(community: community, tapAction: tapAction)
    }
}

final class BrowseCommunityInfoCellModel: BrowseCommunityTableViewCellModel {
    let membersCount: Int?
    let text: String?
    init(community: Community, tapAction: BrowseCommunityViewController.Action, members: Int?, text: String?) {
        self.text = text
        membersCount = members
        super.init(community: community, tapAction: tapAction)
    }
}

final class BrowseCommunityActionCellModel: BrowseCommunityTableViewCellModel {
    let actions: [BrowseCommunityViewController.Action]
    weak var actionConsumer: BrowseCommunityActionConsumer?
    init(community: Community, tapAction: BrowseCommunityViewController.Action, actions: [BrowseCommunityViewController.Action]) {
        self.actions = actions
        super.init(community: community, tapAction: tapAction)
    }
}