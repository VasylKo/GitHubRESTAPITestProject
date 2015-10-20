//
//  CommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

final class CommunityViewController: BrowseModeTabbarViewController, SearchViewControllerDelegate {
    
    var objectId: CRUDObjectId =  CRUDObjectInvalidId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayMode = .List
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override var addMenuItems: [AddMenuView.MenuItem] {
        let pushAndSubscribe: (BaseAddItemViewController) -> () = { [weak self] controller in
            controller.preselectedCommunity = self?.objectId
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
            filter.communities = [ objectId ]
            controller.filter = filter
            return controller
        case .List:
            let community = Community(objectId: objectId)
            let controller = Storyboards.Main.instantiateCommunityFeedViewController()
            controller.community = community
            return controller
        }
    }
    
    override func presentSearchViewController() {
        
        childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
            var f = filter
            f =  SearchFilter.currentFilter
            return f
        }
        canAffectOnFilter = true
        applyDisplayMode(displayMode)
        super.presentSearchViewController()
    }
    
    override func searchViewControllerCancelSearch() {
        childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
            var f = filter
            var user = filter.communities
            f =  SearchFilter.currentFilter
            f.communities = user
            return f
        }
        canAffectOnFilter = true
        applyDisplayMode(displayMode)
    }
    
    override func searchViewControllerItemSelected(model: SearchItemCellModel?) {
        if let model = model {
            
            switch model.itemType {
            case .Unknown:
                break
            case .Category:
                break
            case .Product:
                let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Event:
                let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Promotion:
                let controller =  Storyboards.Main.instantiatePromotionDetailsViewControllerId()
                controller.objectId =  model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Community:
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.communities = [model.objectID]
                    return f
                }
                canAffectOnFilter = false
                applyDisplayMode(displayMode)
            case .People:
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.users = [model.objectID]
                    return f
                }
                canAffectOnFilter = false
                applyDisplayMode(displayMode)
            default:
                break
            }
        }
    }
    
    override func prepareDisplayController(controller: UIViewController) {
        super.prepareDisplayController(controller)
        if let filterUpdate = childFilterUpdate,
            let filterApplicator = controller as? SearchFilterProtocol {
                filterApplicator.applyFilterUpdate(filterUpdate, canAffect: canAffectOnFilter)
        }
            //TODO: need refactor this
        else if let filterUpdate = childFilterUpdate,
            let filterApplicator = controller as? CommunityFeedViewController {
                filterApplicator.canAffectOnFilter = canAffectOnFilter
                filterApplicator.childFilterUpdate = filterUpdate
        }
    }
    
    override func searchViewControllerSectionSelected(model: SearchSectionCellModel?) {
        if let model = model {
            let itemType = model.itemType
            childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                var f = filter
                f.itemTypes = [ itemType ]
                return f
            }
            canAffectOnFilter = false
            applyDisplayMode(displayMode)
        }
    }
    
    var childFilterUpdate: SearchFilterUpdate?
    var canAffectOnFilter: Bool = true
}
