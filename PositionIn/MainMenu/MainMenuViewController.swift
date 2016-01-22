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
        trackGoogleAnalyticsEvent("Main", action: "Click", label: "Home")
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
            MainMenuItem(title: NSLocalizedString("Home", comment: "Main Menu: Home"), imageName: "MainMenuForYou", action: .ForYou),
            MainMenuItem(title: NSLocalizedString("Explore", comment: "Main Menu: Explore"), imageName: "MainMenuNew", action: .New),
            MainMenuItem(title: NSLocalizedString("Messages", comment: "Main Menu: Messages"), imageName: "MainMenuMessages", action: .Messages),
            MainMenuItem(title: NSLocalizedString("Communities", comment: "Main Menu: Community"), imageName: "MainMenuCommunity", action: .Community),
            MainMenuItem(title: NSLocalizedString("People", comment: "Main Menu: People"), imageName: "MainMenuPeople", action: .People),
//            MainMenuItem(title: NSLocalizedString("Wallet", comment: "Main Menu: Wallet"), imageName: "MainMenuWallet", action: .Wallet),
            MainMenuItem(title: NSLocalizedString("Settings", comment: "Main Menu: Settings"), imageName: "MainMenuSettings", action: .Settings),
        ]
    }
    
    private func actionForMode(browseMode: BrowseModeTabbarViewController.BrowseMode) -> SidebarViewController.Action? {
        switch browseMode {
        case .ForYou:
            return .ForYou
        case .New:
            return .New
        }
    }
    
    private func subscribeToNotifications(){
        //Browse mode did change
        let browseModeBlock: NSNotification! -> Void = { [weak self] notification in
            if  let menuController = self,
                let browseController = notification.object as? BrowseViewController,
                let action = menuController.actionForMode(browseController.browseMode) {
                    for (idx, item) in menuController.dataSource.items.enumerate() {
                        if item.action == action {
                            let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                            menuController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
                            break
                        }
                    }
            } // if
        }

        browseModeUpdateObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            BrowseModeTabbarViewController.BrowseModeDidchangeNotification,
            object: nil,
            queue: nil,
            usingBlock: browseModeBlock
        )
        
        //User did change
        let userChangeBlock: NSNotification! -> Void = { [weak self] notification in
            let newProfile = notification.object as? UserProfile
            dispatch_async(dispatch_get_main_queue()) {
                if let menuController = self {
                    menuController.dataSource.items = menuController.menuItemsForUser(newProfile)
                    menuController.tableView.reloadData()
                }
            }
        }
        
        userDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfile.CurrentUserDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: userChangeBlock)
        
        
        //Conversations did change
        let conversationChangeBlock: NSNotification! -> Void = { [weak self] notification in
            dispatch_async(dispatch_get_main_queue()) {
                if let menuController = self {
                    menuController.tableView.reloadData()
                }
            }
        }
        conversationDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            ConversationManager.ConversationsDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: conversationChangeBlock)
    }
    
    
    private var browseModeUpdateObserver: NSObjectProtocol!
    private var userDidChangeObserver: NSObjectProtocol!
    private var conversationDidChangeObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(browseModeUpdateObserver)
        NSNotificationCenter.defaultCenter().removeObserver(userDidChangeObserver)
        NSNotificationCenter.defaultCenter().removeObserver(conversationDidChangeObserver)
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
        
        private func cellModelForItem(item: MainMenuItem) -> TableViewCellModel {
            switch item.action {
            case .Messages:
                let unreadCount = ConversationManager.sharedInstance().countUnreadConversations()
                let badge: String? = unreadCount > 0 ? String(unreadCount) : nil
                return TableViewCellWithBadgetModel(title: item.title, imageName: item.image, badge: badge)
            default:
                return TableViewCellImageTextModel(title: item.title, imageName: item.image)
            }
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
            case .Messages:
                return MainMenuBadgeCell.reuseId()
            default:
                return MainMenuCell.reuseId()
            }
        }

         override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return cellModelForItem(itemForIndexPath(indexPath))
        }
     
        override func nibCellsId() -> [String] {
            return [MainMenuCell.reuseId(), MainMenuUserCell.reuseId(), MainMenuLoginCell.reuseId(), MainMenuBadgeCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = itemForIndexPath(indexPath)
            Log.debug?.message("Select menu item: \(item.title)")
            parentViewController?.sideBarController?.executeAction(item.action)
        }
        
    }
}


