//
//  MainMenuViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class MainMenuViewController: UIViewController {

    @IBOutlet weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.items = defaultMainMenuItems()
        dataSource.configureTable(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func defaultMainMenuItems() -> [MainMenuItem] {
        return [
            MainMenuItem(title: "Username", iconName: nil),
            MainMenuItem(title: NSLocalizedString("For You", comment: "Main Menu: For You"), iconName: "MainMenuForYou"),
            MainMenuItem(title: NSLocalizedString("New", comment: "Main Menu: new"), iconName: "MainMenuNew"),
            MainMenuItem(title: NSLocalizedString("Messages", comment: "Main Menu: Messages"), iconName: "MainMenuMessages"),
            MainMenuItem(title: NSLocalizedString("Filters", comment: "Main Menu: Filters"), iconName: "MainMenuFilters"),
            MainMenuItem(title: NSLocalizedString("Categories", comment: "Main Menu: Categories"), iconName: "MainMenuCategories"),
            MainMenuItem(title: NSLocalizedString("Community", comment: "Main Menu: Community"), iconName: "MainMenuCommunity"),
            MainMenuItem(title: NSLocalizedString("Wallet", comment: "Main Menu: Wallet"), iconName: "MainMenuWallet"),
            MainMenuItem(title: NSLocalizedString("User Profile", comment: "Main Menu: User Profile"), iconName: "MainMenuUserProfile"),
            MainMenuItem(title: NSLocalizedString("Settings", comment: "Main Menu: Settings"), iconName: "MainMenuSettings"),
        ]
    }
    
    private lazy var dataSource: MainMenuItemsDatasource = {
        let dataSource = MainMenuItemsDatasource()
        dataSource.parentViewController = self
        return dataSource
    }()
    
    
    internal struct MainMenuItem {
        let title: String
        let iconName: String?
        
    }
    
    
    internal class MainMenuItemsDatasource: TableViewDataSource  {

        var items: [MainMenuItem] = []
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return MainMenuCell.reuseId()
        }

         override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = items[indexPath.row]
            let model = TableViewCellImageTextModel(title: item.title, imageName: item.iconName ?? "")
            return model
        }
     
        override func nibCellsId() -> [String] {
            return [MainMenuCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = items[indexPath.row]
            println("Item: \(item.title)")
        }
        
    }
}


