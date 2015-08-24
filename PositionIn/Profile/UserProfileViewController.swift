//
//  UserProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

final class UserProfileViewController: BrowseModeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayMode = .List
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.displayMode {
        case .Map:
            return Storyboards.Main.instantiateBrowseMapViewController()
        case .List:
            return Storyboards.Main.instantiateProfileListViewController()
        }
    }
    
    
}
