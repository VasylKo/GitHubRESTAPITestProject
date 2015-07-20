//
//  SidebarViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import KYDrawerController

class SidebarViewController: KYDrawerController {
    enum Action  {
        case None
        
        case ForYou
        case New
        case Messages
        case Filters
        case Categories
        case Community
        case Wallet
        case UserProfile
        case Settings
    }

    func executeAction(action: Action) {
        let (segue: SidebarViewController.Segue?, sender: AnyObject?) = {
            switch action {
            case .Messages:
                return (SidebarViewController.Segue.ShowMessagesList, nil)
            case .ForYou, .New:
                return (SidebarViewController.Segue.ShowBrowse, nil)
            default:
                return (nil, nil)
            }
            }()
        if let segue = segue {
            setDrawerState(.Closed, animated: true)
            performSegue(segue, sender: sender)
        }
    }

}

extension UIViewController {
    var sideBarController: SidebarViewController? {
        if let sideBar = searchSideBarController(self.navigationController) {
            return sideBar
        }
        return searchSideBarController(self)
    }
    
    private func searchSideBarController(controller: UIViewController?) -> SidebarViewController? {
        switch controller {
        case .None:
            return nil
        default:
            if let c = controller as? SidebarViewController {
                return c
            }
        }
        return searchSideBarController(controller?.parentViewController)
    }

}