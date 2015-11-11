//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol UpdateFilterProtocol {
    func applyFilterUpdate(update: SearchFilterUpdate)
}

final class BrowseViewController: BrowseModeTabbarViewController {
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.displayMode {
        case .Map:
            let mapController = Storyboards.Main.instantiateBrowseMapViewController()
            mapController.delegate = self
            return mapController
        case .List:
            let listController = Storyboards.Main.instantiateBrowseListViewController()
            listController.hideSeparatorLinesNearSegmentedControl = true
            return listController
        }
    }
    
    override var addMenuItems: [AddMenuView.MenuItem] {
        let pushAndSubscribe: (UIViewController) -> () = { [weak self] controller in
            self?.navigationController?.pushViewController(controller, animated: true)
            self?.subscribeForContentUpdates(controller)
        }
        return [
            AddMenuView.MenuItem.productItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    pushAndSubscribe(Storyboards.NewItems.instantiateAddProductViewController())
                }},
            AddMenuView.MenuItem.eventItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    pushAndSubscribe(Storyboards.NewItems.instantiateAddEventViewController())
                }},
            AddMenuView.MenuItem.promotionItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in pushAndSubscribe(Storyboards.NewItems.instantiateAddPromotionViewController())
                }},
            AddMenuView.MenuItem.postItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    pushAndSubscribe(Storyboards.NewItems.instantiateAddPostViewController())
                }},
            AddMenuView.MenuItem.inviteItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    Log.error?.message("Should call invite")}
            },
        ]
    }
    
    override func presentSearchViewController(filter: SearchFilter) {
        
        childFilterUpdate = nil
        applyDisplayMode(displayMode)
        super.presentSearchViewController(filter)
    }
    
    override func prepareDisplayController(controller: UIViewController) {
        super.prepareDisplayController(controller)
        if let filterUpdate = childFilterUpdate,
           let filterApplicator = controller as? UpdateFilterProtocol {
            filterApplicator.applyFilterUpdate(filterUpdate)
        }
    }
}
