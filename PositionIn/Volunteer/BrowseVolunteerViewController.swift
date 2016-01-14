//
//  VolunteerViewController.swift
//  PositionIn
//
//  Created by ng on 1/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import BrightFutures
import CleanroomLogger

class BrowseVolunteerViewController: BrowseCommunityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let communitiesRequest: Future<CollectionResponse<Community>, NSError>
        let browseMode = self.browseMode
        switch browseMode {
        case .MyGroups:
            let mySubscriptionsRequest = api().currentUserId().flatMap { userId in
                return api().getUserCommunities(userId)
            }
            if firstMyCommunityRequestToken.isInvalid {
                communitiesRequest = mySubscriptionsRequest
            } else {
                // On first load switch to explore if not join any community
                firstMyCommunityRequestToken.invalidate()
                communitiesRequest = mySubscriptionsRequest.flatMap {  response -> Future<CollectionResponse<Community>,NSError> in
                    if let communitiesList = response.items  where communitiesList.count == 0 {
                        return Future(error: NetworkDataProvider.ErrorCodes.InvalidRequestError.error())
                    } else {
                        return Future(value: response)
                    }
                    }.andThen { [weak self] result in
                        switch result {
                        case .Failure(_):
                            self?.browseMode = .Explore
                        default:
                            break
                        }
                }
            }
        case .Explore:
            communitiesRequest = api().getCommunities(APIService.Page())
        }
        communitiesRequest.onSuccess(dataRequestToken.validContext) { [weak self] response in
            if let communities = response.items {
                Log.debug?.value(communities)
                self?.dataSource.setCommunities(communities, mode: browseMode)
                self?.tableView.reloadData()
            }
        }
    }
    
    override func executeAction(action: BrowseCommunityViewController.Action, community: CRUDObjectId) {
        switch action {
        case .Join:
            if api().isUserAuthorized() {
                api().joinCommunity(community).onSuccess { [weak self] _ in
                    self?.reloadData()
                    ConversationManager.sharedInstance().refresh()
                }
            }
            else {
                api().logout().onComplete {[weak self] _ in
                    self?.sideBarController?.executeAction(.Login)
                }
            }
            break
        case .Browse, .Post:
            let controller = Storyboards.Main.instantiateCommunityViewController()
            controller.objectId = community
            navigationController?.pushViewController(controller, animated: true)
        case .Invite:
            break
        case .Edit:
            let controller = Storyboards.NewItems.instantiateEditCommunityViewController()
            controller.existingCommunityId = community
            navigationController?.pushViewController(controller, animated: true)
            self.subscribeForContentUpdates(controller)
        case .None:
            break
        }
    }
}