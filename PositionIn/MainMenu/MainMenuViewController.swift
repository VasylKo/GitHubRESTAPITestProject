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
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        tableView.reloadData()

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
            MainMenuItem(title: NSLocalizedString("For You", comment: "Main Menu: For You"), iconName: nil),
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
    
    
    private class MainMenuItemsDatasource: TableViewDataSource {

        var items: [MainMenuItem] = []
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return NSStringFromClass(MainMenuCell)
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return "Hello"
//            let model = TableViewCellTextModel(title: "Hello")
//            return model
        }
        
    }
}


extension String: TableViewCellModel {
    
}