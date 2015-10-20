//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol SearchFilterProtocol {
    var filter: SearchFilter {get set}
    func applyFilterUpdate(update: SearchFilterUpdate, canAffect: Bool)
    var canAffectFilter: Bool {get set}
}

final class BrowseViewController: BrowseModeTabbarViewController, SearchViewControllerDelegate {
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.displayMode {
        case .Map:
            return Storyboards.Main.instantiateBrowseMapViewController()
        case .List:
            return Storyboards.Main.instantiateBrowseListViewController()
        }
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
    
    override func searchViewControllerItemSelected(model: SearchItemCellModel?, searchString: String?, locationString: String?) {
        super.searchViewControllerItemSelected(model, searchString: searchString, locationString: locationString)
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

    override func searchViewControllerSectionSelected(model: SearchSectionCellModel?, searchString: String?, locationString: String?) {
        super.searchViewControllerSectionSelected(model, searchString: searchString, locationString: locationString)
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
    
    override func prepareDisplayController(controller: UIViewController) {
        super.prepareDisplayController(controller)
        if let filterUpdate = childFilterUpdate,
           let filterApplicator = controller as? SearchFilterProtocol {
            filterApplicator.applyFilterUpdate(filterUpdate, canAffect: canAffectOnFilter)
        }
    }
}
