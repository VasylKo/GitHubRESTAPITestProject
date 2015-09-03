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
        case Call, Chat, Edit
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
        return [
            AddMenuView.MenuItem.productItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddProductViewController(), animated: true)
            },
            AddMenuView.MenuItem.eventItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddEventViewController(), animated: true)
            },
            AddMenuView.MenuItem.promotionItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPromotionViewController(), animated: true)
            },
            AddMenuView.MenuItem.postItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPostViewController(), animated: true)
            },
            AddMenuView.MenuItem.inviteItemWithAction { [weak self] in
                Log.debug?.message("Should call invite")
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
    
    
}

extension UserProfileViewController: UserProfileActionConsumer {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction) {
        Log.debug?.value(action)
        switch action {
        case .Edit:
            navigationController?.pushViewController(Storyboards.NewItems.instantiateEditProfileViewController(), animated: true)
        case .None:
            fallthrough
        default:
            Log.warning?.message("Unhandled action \(action)")
        }
    }

}