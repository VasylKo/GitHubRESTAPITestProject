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
