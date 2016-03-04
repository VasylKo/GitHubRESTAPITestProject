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
    
    //override var mapViewController = VolunteerMapViewController() as UIViewCo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Volunteering"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let volunteerDetailsViewController = segue.destinationViewController  as? VolunteerDetailsViewController {
            volunteerDetailsViewController.volunteer = self.selectedObject
            volunteerDetailsViewController.joinAction = (self.browseModeSegmentedControl.selectedSegmentIndex == 1) 
            volunteerDetailsViewController.type = VolunteerDetailsViewController.ControllerType.Volunteer
            volunteerDetailsViewController.author = self.selectedObject?.owner
        }
    }
    
    override func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let communitiesRequest: Future<CollectionResponse<Community>, NSError>
        let browseMode = self.browseMode
        switch browseMode {
        case .MyGroups:
            let mySubscriptionsRequest = api().currentUserId().flatMap { userId in
                return api().getUserVolunteers(userId)
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
            communitiesRequest =  api().getVolunteers()
        }
        communitiesRequest.onSuccess(dataRequestToken.validContext) { [weak self] response in
            if let communities = response.items {
                Log.debug?.value(communities)
                
//               TODO should fix than, (hide lock icon on volunteer)
                var updateCommunity: [Community] = []
                for var community in communities {
                    community.closed = nil
                    updateCommunity.append(community)
                }
                self?.dataSource.setCommunities(updateCommunity, mode: browseMode)
                self?.tableView.reloadData()
            }
        }
    }
    
    override func executeAction(action: BrowseCommunityViewController.Action, community: Community) {
        let communityId = community.objectId
        switch action {
        case .Join:
            if api().isUserAuthorized() {
                api().joinCommunity(communityId).onSuccess { [weak self] _ in
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
        case .Post:
            let controller = Storyboards.NewItems.instantiateAddPostViewController()
            controller.communityId = communityId
            navigationController?.pushViewController(controller, animated: true)
        case .Browse, .None:
            switch self.browseModeSegmentedControl.selectedSegmentIndex {
            case 0:
                let controller = Storyboards.Main.instantiateCommunityViewController()
                controller.objectId = communityId
                controller.controllerType = .Volunteer
                navigationController?.pushViewController(controller, animated: true)
            case 1:
                self.selectedObject = community
                self.performSegue(BrowseCommunityViewController.Segue.showVolunteerDetailsViewController)
            default:
                break
            }
        case .Invite:
            break
        case .Edit:
            let controller = Storyboards.NewItems.instantiateEditCommunityViewController()
            controller.existingCommunityId = communityId
            navigationController?.pushViewController(controller, animated: true)
            self.subscribeForContentUpdates(controller)
        case .Leave:
            api().leaveVolunteer(communityId).onSuccess(callback: { (Void) -> Void in
                self.reloadData()
            })
        }
    }
}