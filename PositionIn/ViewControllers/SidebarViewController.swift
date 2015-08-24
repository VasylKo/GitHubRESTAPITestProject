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
import Box

class SidebarViewController: KYDrawerController {
    enum Action  {
        case None
        
        case ForYou
        case New
        case Messages
        case Filters
        case Community
        case Wallet
        case UserProfile
        case Settings
        case Login
        
        func nextController() -> UIViewController? {
            switch self {
            case .Login:
                return Storyboards.Login.instantiateInitialViewController()
            default:
                return nil
            }
        }
        
        func nextSegue() -> SegueInfo? {
            switch self {
            case .Messages:
                return (SidebarViewController.Segue.ShowMessagesList, nil)
            case .ForYou:
                return (SidebarViewController.Segue.ShowBrowse, Box(DisplayModeViewController.DisplayMode.Map, BrowseModeViewController.BrowseMode.ForYou))
            case .New:
                return (SidebarViewController.Segue.ShowBrowse, Box(DisplayModeViewController.DisplayMode.Map, BrowseModeViewController.BrowseMode.New))
            case .Filters:
                return (SidebarViewController.Segue.ShowFilters, nil)
            case .Community:
                return (SidebarViewController.Segue.ShowCommunities, nil)
            case .Settings:
                return (SidebarViewController.Segue.ShowSettings, nil)
            case .UserProfile:
                return (SidebarViewController.Segue.ShowMyProfile, nil)
            default:
                return nil
            }
        }
        
        typealias SegueInfo = (segue: SidebarViewController.Segue, sender: AnyObject?)
    }

    func executeAction(action: Action) {
        if !isViewLoaded() {
            dispatch_delay(0){ self.executeAction(action) }
            return
        }
        
        setDrawerState(.Closed, animated: true)
        
        if let controller = action.nextController() {
            presentViewController(controller, animated: true, completion: nil)
        }
        
        if let (segue, sender: AnyObject?) = action.nextSegue() {
            performSegue(segue, sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = segue.identifier {
            switch segueId {
            case SidebarViewController.Segue.ShowBrowse.identifier!:
                if let navigationController = segue.destinationViewController as? UINavigationController,
                   let browseController = navigationController.topViewController as? BrowseViewController,
                   let mode = sender as? Box<(DisplayModeViewController.DisplayMode, BrowseModeViewController.BrowseMode)> {
                    let (displayMode, browseMode) = mode.value
                        browseController.displayMode = displayMode
                        browseController.browseMode = browseMode
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
        if let sideBar = searchSideBarController(self.presentingViewController) {
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