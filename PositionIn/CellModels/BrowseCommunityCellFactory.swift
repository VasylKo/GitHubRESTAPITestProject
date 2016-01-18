//
//  BrowseCommunityCellFactory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

struct BrowseCommunityCellFactory {
    func modelsForCommunity(community: Community, mode: BrowseCommunityViewController.BrowseMode, actionConsumer: BrowseCommunityActionConsumer?) -> [TableViewCellModel] {
        var models: [TableViewCellModel] = []
        let tapAction = tapActionForCommunity(community)
        models.append(BrowseCommunityHeaderCellModel(objectId: community.objectId, tapAction: tapAction, title:community.name ?? "", url:community.avatar, showInfo: false, isClosed: community.closed))
        
        models.append(BrowseCommunityInfoCellModel(objectId: community.objectId, tapAction: tapAction, members: community.members?.total, text: community.communityDescription))

        let actionModel = BrowseCommunityActionCellModel(objectId: community.objectId, tapAction: tapAction, actions: actionListForCommunity(community))
        actionModel.actionConsumer = actionConsumer
        models.append(actionModel)
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

    private func actionListForCommunity(community: Community) -> [BrowseCommunityViewController.Action] {
        Log.debug?.value(community.role)
        switch community.role {
        case .Invite, .Unknown:
            return [.Browse]
        case .Owner:
            return [.Post, .Browse /*.Invite,*/]
        case .Moderator:
            return [.Post, .Browse, .Leave /*.Invite*/]
        default:
            if community.closed {
                return [.Post, .Browse, .Leave]
            } else {
                return [.Post, .Browse, .Leave /*.Invite*/]
            }
        }
        
    }
    
    private func tapActionForCommunity(community: Community) -> BrowseCommunityViewController.Action {
        return community.canView ? .Browse : .None
    }
}
