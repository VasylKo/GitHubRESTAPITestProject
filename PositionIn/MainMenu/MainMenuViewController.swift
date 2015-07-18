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

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.items = defaultMainMenuItems()
        dataSource.tableView = tableView
//        let t = TableViewDataSource()
//        t.tableView(tableView, numberOfRowsInSection: 0)

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
        return MainMenuItemsDatasource(viewController: self, table: self.tableView)
    }()
    
    
    private struct MainMenuItem {
        let title: String
        let iconName: String?
    }
    
    
    private class MainMenuItemsDatasource: NSObject, UITableViewDataSource {
        init(viewController: UIViewController, table: UITableView) {
            parentViewController = viewController
            tableView = table
        }
        
        unowned let parentViewController: UIViewController
        weak var tableView: UITableView? {
            didSet {
                tableView?.dataSource = self
                reloadData()
            }
        }
        var items: [MainMenuItem] = [] {
            didSet {
                reloadData()
            }
        }
        
        func reloadData() {
            tableView?.reloadData()
        }
        
        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            //TODO: refactor
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "MainMenu cell")
            let item = items[indexPath.row]
            cell.textLabel?.text = item.title
            return cell
        }
    }

    @IBOutlet weak var tableView: UITableView!
}
