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
        dataSource.items = defaultMainMenuItems()
        dataSource.configureTable(tableView)
        subscribeToNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func defaultMainMenuItems() -> [MainMenuItem] {
        //TODO: refactor
        return [
            MainMenuItem(title: "Username", imageName: "https://pbs.twimg.com/profile_images/3255786215/509fd5bc902d71141990920bf207edea.jpeg", action: .Login),
            MainMenuItem(title: NSLocalizedString("For You", comment: "Main Menu: For You"), imageName: "MainMenuForYou", action: .ForYou),
            MainMenuItem(title: NSLocalizedString("New", comment: "Main Menu: new"), imageName: "MainMenuNew", action: .New),
            MainMenuItem(title: NSLocalizedString("Messages", comment: "Main Menu: Messages"), imageName: "MainMenuMessages", action: .Messages),
            MainMenuItem(title: NSLocalizedString("Filters", comment: "Main Menu: Filters"), imageName: "MainMenuFilters", action: .Filters),
            MainMenuItem(title: NSLocalizedString("Community", comment: "Main Menu: Community"), imageName: "MainMenuCommunity", action: .Community),
            MainMenuItem(title: NSLocalizedString("People", comment: "Main Menu: People"), imageName: "MainMenuCommunity"),            
            MainMenuItem(title: NSLocalizedString("Wallet", comment: "Main Menu: Wallet"), imageName: "MainMenuWallet"),
            MainMenuItem(title: NSLocalizedString("Settings", comment: "Main Menu: Settings"), imageName: "MainMenuSettings"),
        ]
    }
    
    private func actionForMode(browseMode: BrowseViewController.BrowseMode) -> SidebarViewController.Action? {
        switch browseMode {
        case .ForYou:
            return .ForYou
        case .New:
            return .New
        }
    }
    
    private func subscribeToNotifications(){
        let block: NSNotification! -> Void = { [weak self] notification in
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
            BrowseViewController.BrowseModeDidchangeNotification,
            object: nil,
            queue: nil,
            usingBlock: block
        )
    }
    
    private var browseModeUpdateObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(browseModeUpdateObserver)
    }
    
    
    private lazy var dataSource: MainMenuItemsDatasource = {
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
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            if indexPath.row == 0 {
                return  MainMenuUserCell.reuseId()
            }
            return MainMenuCell.reuseId()
        }

         override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = items[indexPath.row]
            let model = TableViewCellImageTextModel(title: item.title, imageName: item.image)
            return model
        }
     
        override func nibCellsId() -> [String] {
            return [MainMenuCell.reuseId(), MainMenuUserCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = items[indexPath.row]
            Log.debug?.message("Select menu item: \(item.title)")
            parentViewController?.sideBarController?.executeAction(item.action)
        }
        
    }
}


