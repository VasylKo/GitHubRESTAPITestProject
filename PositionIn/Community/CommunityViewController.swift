//
//  CommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

final class CommunityViewController: DisplayModeViewController {
    
    var objectId: CRUDObjectId =  CRUDObjectInvalidId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayMode = .List
        self.navigationItem.titleView = nil
        self.title = NSLocalizedString("Community", comment: "CommunityViewController")
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
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
    
    override func presentSearchViewController(filter: SearchFilter) {
        childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
            var f = filter
            f =  SearchFilter.currentFilter
            return f
        }
        applyDisplayMode(displayMode)
        
        var searchFilter: SearchFilter = SearchFilter.currentFilter
        searchFilter.communities = [ objectId ]

        super.presentSearchViewController(searchFilter)
    }
    
    override func searchViewControllerCancelSearch() {
        super.searchViewControllerCancelSearch()
        childFilterUpdate = nil
        applyDisplayMode(displayMode)
    }
    
    override func prepareDisplayController(controller: UIViewController) {
        super.prepareDisplayController(controller)
        if let filterUpdate = childFilterUpdate,
            let filterApplicator = controller as? UpdateFilterProtocol {
                filterApplicator.applyFilterUpdate(filterUpdate)
        }
    }
}
