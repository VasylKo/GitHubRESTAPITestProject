//
//  UserProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol UserProfileActionConsumer: class {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction)
}

final class UserProfileViewController: BrowseModeViewController {
    
    enum ProfileAction: Int, Printable {
        case None
        case Call, Chat, Edit, Follow, UnFollow
        var description: String {
            switch self {
            case .None:
                return "Empty action"
            case .Call:
                return "Contact"
            case .Chat:
                return "SendMessage"
            case .Edit:
                return "Edit profile"
            case .Follow:
                return "Follow"
            case .UnFollow:
                return "Unfollow"
            }
        }

    }
    
    var objectId: CRUDObjectId = api().currentUserId() ?? CRUDObjectInvalidId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayMode = .List
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override var addMenuItems: [AddMenuView.MenuItem] {
        let pushAndSubscribe: (UIViewController) -> () = { [weak self] controller in
            self?.navigationController?.pushViewController(controller, animated: true)
            self?.subscribeForContentUpdates(controller)
        }
        return [
            AddMenuView.MenuItem.productItemWithAction { pushAndSubscribe(Storyboards.NewItems.instantiateAddProductViewController()) },
            AddMenuView.MenuItem.eventItemWithAction { pushAndSubscribe(Storyboards.NewItems.instantiateAddEventViewController()) },
            AddMenuView.MenuItem.promotionItemWithAction { pushAndSubscribe(Storyboards.NewItems.instantiateAddPromotionViewController()) },
            AddMenuView.MenuItem.postItemWithAction { pushAndSubscribe(Storyboards.NewItems.instantiateAddPostViewController()) },
            AddMenuView.MenuItem.inviteItemWithAction { [weak self] in
                Log.error?.message("Should call invite")
            },
        ]
    }
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.displayMode {
        case .Map:
            let controller = Storyboards.Main.instantiateBrowseMapViewController()
            var filter = controller.filter
            filter.users = [ objectId ]
            controller.filter = filter
            return controller
        case .List:
            let profile = UserProfile(objectId: objectId)
            let controller = Storyboards.Main.instantiateProfileListViewController()
            controller.profile = profile
            return controller
        }
    }
    
    static let SubscriptionDidChangeNotification = "SubscriptionDidChangeNotification"
    
    private func sendSubscriptionUpdateNotification(aUserInfo: [NSObject : AnyObject]? = nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            UserProfileViewController.SubscriptionDidChangeNotification,
            object: self,
            userInfo: nil
        )
    }
}

extension UserProfileViewController: UserProfileActionConsumer {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction) {
        switch action {
        case .Edit:
            let updateController = Storyboards.NewItems.instantiateEditProfileViewController()
            subscribeForContentUpdates(updateController)
            navigationController?.pushViewController(updateController, animated: true)
        case .Follow:
            api().followUser(objectId).onSuccess { [weak self] in
                self?.displayMode = .List
                self?.sendSubscriptionUpdateNotification(aUserInfo: nil)
            }
        case .UnFollow:
            api().unFollowUser(objectId).onSuccess { [weak self] in
                self?.displayMode = .List
                self?.sendSubscriptionUpdateNotification(aUserInfo: nil)
            }
        case .Chat:
            let chatController = ConversationViewController.conversationController()
            navigationController?.pushViewController(chatController, animated: true)
        case .None:
            fallthrough
        default:
            Log.warning?.message("Unhandled action \(action)")
        }
    }

}