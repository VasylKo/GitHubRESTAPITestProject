//
//  BrowseCommunityCellFactory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

struct BrowseCommunityCellFactory {
    func modelsForCommunity(community: Community, mode: BrowseCommunityViewController.BrowseMode) -> [TableViewCellModel] {
        var models: [TableViewCellModel] = []
        models.append(BrowseCommunityHeaderCellModel(objectId: community.objectId, title:community.name ?? "", url:community.avatar))
        models.append(BrowseCommunityInfoCellModel(objectId: community.objectId, members: community.members?.total, text: community.communityDescription))
        models.append(BrowseCommunityActionCellModel(objectId: community.objectId, actions:actionsForCommunity(community)))
        return models
    }
    
    func communityCellsReuseId() -> [String]  {
        return [CommunityInfoCell.reuseId(),CommunityActionCell.reuseId(), CommunityHeaderCell.reuseId()]
    }
    
    func cellReuseIdForModel(model: TableViewCellModel) -> String {
        
        if model is BrowseCommunityHeaderCellModel {
            return CommunityHeaderCell.reuseId()
        }
        if model is BrowseCommunityInfoCellModel {
            return CommunityInfoCell.reuseId()
        }
        if model is BrowseCommunityActionCellModel {
            return CommunityActionCell.reuseId()
        }
        
        return TableViewCell.reuseId()
    }

    private func actionsForCommunity(community: Community) -> [BrowseCommunityViewController.Action] {
        return []
    }

}
