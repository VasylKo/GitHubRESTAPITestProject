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
        models.append(BrowseCommunityHeaderCellModel(community: community, tapAction: tapAction, title:community.name ?? "", url:community.avatar, showInfo: false, isClosed: community.closed))
        
        models.append(BrowseCommunityInfoCellModel(community: community, tapAction: tapAction, members: community.membersCount, text: community.communityDescription))

        let actionModel = BrowseCommunityActionCellModel(community: community, tapAction: tapAction, actions: actionListForCommunity(community))
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
        case .Invitee, .Unknown:
            return [.Browse]
        case .Owner:
            return [.Post, .Browse /*.Invite,*/]
        case .Moderator:
            return [.Post, .Browse, .Leave /*.Invite*/]
        case .Applicant:
            return [.Browse]
        default:
            if let closed = community.closed {
                if closed {
                    return [.Post, .Browse, .Leave]
                } else {
                    return [.Post, .Browse, .Leave /*.Invite*/]
                }
            }
            else {
                return [.Browse, /*.Invite*/]
            }
        }
        
    }
    
    private func tapActionForCommunity(community: Community) -> BrowseCommunityViewController.Action {
        return community.canView ? .Browse : .None
    }
}
