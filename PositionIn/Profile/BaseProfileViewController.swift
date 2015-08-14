//
//  BaseProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class BaseProfileViewController: BesideMenuViewController {
    @IBOutlet weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    
    func prepareDatasource(dataSource: ProfileDataSource) {
        dataSource.items = [ ProfileInfoCellModel(name: "Hello", avatar: nil, background: nil)]
    }
    
    
    lazy var dataSource: ProfileDataSource = {
        let dataSource = ProfileDataSource()
        dataSource.parentViewController = self
        self.prepareDatasource(dataSource)
        return dataSource
        }()
}


protocol ProfileCellModel: TableViewCellModel {
}

extension BaseProfileViewController {
    final class ProfileDataSource: TableViewDataSource {
        var items: [ProfileCellModel] = []
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return count(items)
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ProfileInfoCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.row]
            
        }
        
        override func nibCellsId() -> [String] {
            return [ProfileInfoCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

        }
    }
}