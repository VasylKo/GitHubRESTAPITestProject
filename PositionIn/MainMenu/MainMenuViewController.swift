//
//  MainMenuViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class MainMenuViewController: UIViewController {

    @IBOutlet private weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.items = menuItemsForUser(nil)
        dataSource.configureTable(tableView)
        subscribeToNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func menuItemsForUser(user: UserProfile?) -> [MainMenuItem] {
        
        let loginItem = MainMenuItem(title: NSLocalizedString("Login", comment: "Main Menu: Login"), imageName: "MainMenuPeople", action: .Login)
        let firstItem: MainMenuItem =  user.map { user in
            if user.guest == true {
                return loginItem
            }

            let image = user.avatar?.absoluteString ?? ""
            return MainMenuItem(title: user.displayName, imageName: image, action: .UserProfile)
        } ?? loginItem

        return [firstItem] + defaultMainMenuItems()
    }
    
    private func defaultMainMenuItems() -> [MainMenuItem] {
        //TODO: refactor
        return [
            MainMenuItem(title: NSLocalizedString("For You", comment: "Main Menu: For You"), imageName: "MainMenuForYou", action: .ForYou),
            MainMenuItem(title: NSLocalizedString("New", comment: "Main Menu: new"), imageName: "MainMenuNew", action: .New),
            MainMenuItem(title: NSLocalizedString("Messages", comment: "Main Menu: Messages"), imageName: "MainMenuMessages", action: .Messages),
            MainMenuItem(title: NSLocalizedString("Filters", comment: "Main Menu: Filters"), imageName: "MainMenuFilters", action: .Filters),
            MainMenuItem(title: NSLocalizedString("Communities", comment: "Main Menu: Community"), imageName: "MainMenuCommunity", action: .Community),
            MainMenuItem(title: NSLocalizedString("People", comment: "Main Menu: People"), imageName: "MainMenuPeople", action: .People),
            MainMenuItem(title: NSLocalizedString("Wallet", comment: "Main Menu: Wallet"), imageName: "MainMenuWallet", action: .Wallet),
            MainMenuItem(title: NSLocalizedString("Settings", comment: "Main Menu: Settings"), imageName: "MainMenuSettings", action: .Settings),
        ]
    }
    
    private func actionForMode(browseMode: BrowseModeViewController.BrowseMode) -> SidebarViewController.Action? {
        switch browseMode {
        case .ForYou:
            return .ForYou
        case .New:
            return .New
        }
    }
    
    private func subscribeToNotifications(){
        let browseModeBlock: NSNotification! -> Void = { [weak self] notification in
            if  let menuController = self,
                let browseController = notification.object as? BrowseViewController,
                let action = menuController.actionForMode(browseController.browseMode) {
                    for (idx, item) in enumerate(menuController.dataSource.items) {
                        if item.action == action {
                            let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                            menuController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
                            break
                        }
                    }
            } // if
        }

        browseModeUpdateObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            BrowseModeViewController.BrowseModeDidchangeNotification,
            object: nil,
            queue: nil,
            usingBlock: browseModeBlock
        )
        
        let userChangeBlock: NSNotification! -> Void = { [weak self] notification in
            let newProfile = notification.object as? UserProfile
            dispatch_async(dispatch_get_main_queue()) {
                if let menuController = self {
                    menuController.dataSource.items = menuController.menuItemsForUser(newProfile)
                    menuController.tableView.reloadData()
                }
            }
        }
        
        userDidChangeNotification = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfile.CurrentUserDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: userChangeBlock)
    }
    
    
    private var browseModeUpdateObserver: NSObjectProtocol!
    private var userDidChangeNotification: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(browseModeUpdateObserver)
        NSNotificationCenter.defaultCenter().removeObserver(userDidChangeNotification)
    }
    
    
    private lazy var dataSource: MainMenuItemsDatasource = { [unowned self] in
        let dataSource = MainMenuItemsDatasource()
        dataSource.parentViewController = self
        return dataSource
    }()
    
    
    
    internal struct MainMenuItem {
        let title: String
        let image: String
        let action: SidebarViewController.Action
        init(title: String, imageName: String, action: SidebarViewController.Action = .None){
            self.title = title
            image = imageName
            self.action = action
        }
    }
    
    
    internal class MainMenuItemsDatasource: TableViewDataSource  {

        var items: [MainMenuItem] = []
        
        private func itemForIndexPath(indexPath: NSIndexPath) -> MainMenuItem {
            return items[indexPath.row]
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            switch itemForIndexPath(indexPath).action {
            case .Login:
                return MainMenuLoginCell.reuseId()
            case .UserProfile:
                return  MainMenuUserCell.reuseId()
            default:
                return MainMenuCell.reuseId()
            }
        }

         override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = itemForIndexPath(indexPath)
            let model = TableViewCellImageTextModel(title: item.title, imageName: item.image)
            return model
        }
     
        override func nibCellsId() -> [String] {
            return [MainMenuCell.reuseId(), MainMenuUserCell.reuseId(), MainMenuLoginCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = itemForIndexPath(indexPath)
            Log.debug?.message("Select menu item: \(item.title)")
            parentViewController?.sideBarController?.executeAction(item.action)
        }
        
    }
}


