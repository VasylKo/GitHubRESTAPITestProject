//
//  ExploreViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 23/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//


import UIKit


class ExploreViewController: DisplayModeViewController {
    
    var homeItem: HomeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = nil
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
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
            switch mode {
            case .Map:
                let mapController = Storyboards.Main.instantiateBrowseMapViewController()
                mapController.delegate = self
                return mapController
            case .List:
                let listController = Storyboards.Main.instantiateBrowseListViewController()
                listController.homeItem = homeItem
                listController.hideSeparatorLinesNearSegmentedControl = true
                listController.showCardCells = false
                return listController
        }
    }
}