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
    func reloadData()
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

    override func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        super.searchBarShouldBeginEditing(searchBar)
        
        return true
    }
    
    override func searchViewControllerItemSelected(model: SearchItemCellModel?) {
        if let model = model {
            if var filterApplicator = self.currentModeViewController as? SearchFilterProtocol {
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
                    filterApplicator.filter.communities = [model.objectID]
                case .People:
                    filterApplicator.filter.users = [model.objectID]
                default:
                    break
                }
                filterApplicator.reloadData()
            }
        }
    }

    override func searchViewControllerSectionSelected(model: SearchSectionCellModel?) {
        let controller = self.currentModeViewController
        if let model = model {
            if var filterApplicator = self.currentModeViewController as? SearchFilterProtocol {
                switch model.itemType {
                case .Unknown:
                    break;
                case .Event:
                    filterApplicator.filter.itemTypes = [.Event]
                case .Promotion:
                    filterApplicator.filter.itemTypes = [.Promotion]
                case .Item:
                    filterApplicator.filter.itemTypes = [.Item]
                case .Post:
                    filterApplicator.filter.itemTypes = [.Post]
                }
                filterApplicator.reloadData()
            }
        }
    }
}
