//
//  SidebarViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import KYDrawerController
import PosInCore

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
                return (SidebarViewController.Segue.ShowBrowse, Box(BrowseViewController.DisplayMode.Map))
            default:
                return (nil, nil)
            }
            }()
        if let segue = segue {
            setDrawerState(.Closed, animated: true)
            performSegue(segue, sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = segue.identifier {
            switch segueId {
            case SidebarViewController.Segue.ShowBrowse.identifier!:
                if let navigationController = segue.destinationViewController as? UINavigationController,
                   let browseController = navigationController.topViewController as? BrowseViewController,
                   let mode = sender as? Box<BrowseViewController.DisplayMode> {
                        browseController.mode = mode.unbox
                }
            default:
                return
            }
        }
    }
    
    override func setDrawerState(state: KYDrawerController.DrawerState, animated: Bool) {
        super.setDrawerState(state, animated: animated)
        mainViewController?.view.endEditing(true)        
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