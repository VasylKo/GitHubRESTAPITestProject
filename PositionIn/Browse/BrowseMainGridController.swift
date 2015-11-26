//
//  BrowseMainGridController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class BrowseMainGridController: BrowseModeTabbarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = nil
    }
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.browseMode {
        case .ForYou:
            self.navigationItem.rightBarButtonItems = nil
            return Storyboards.Main.instantiateBrowseGridViewController()
        case .New:
            super.setRightBarItems()
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
    }
    
    override var addMenuItems: [AddMenuView.MenuItem] {
        let pushAndSubscribe: (UIViewController) -> () = { [weak self] controller in
            self?.navigationController?.pushViewController(controller, animated: true)
            self?.subscribeForContentUpdates(controller)
        }
        return [
            AddMenuView.MenuItem.promotionItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in pushAndSubscribe(Storyboards.NewItems.instantiateAddPromotionViewController())
                }},
//            AddMenuView.MenuItem.eventItemWithAction {
//                api().isUserAuthorized().onSuccess {  _ in
//                    pushAndSubscribe(Storyboards.NewItems.instantiateAddEventViewController())
//                }},
//            AddMenuView.MenuItem.productItemWithAction {
//                api().isUserAuthorized().onSuccess {  _ in
//                    pushAndSubscribe(Storyboards.NewItems.instantiateAddProductViewController())
//                }},
            AddMenuView.MenuItem.postItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    pushAndSubscribe(Storyboards.NewItems.instantiateAddPostViewController())
                }},
            AddMenuView.MenuItem.inviteItemWithAction {
                api().isUserAuthorized().onSuccess {  _ in
                    Log.error?.message("Should call invite")
                }},
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
