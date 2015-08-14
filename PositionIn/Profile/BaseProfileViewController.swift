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

    func prepareDatasource(dataSource: ProfileDataSource) {
        
    }
    
    
    lazy var dataSource: ProfileDataSource = {
        let dataSource = ProfileDataSource()
        dataSource.parentViewController = self
        self.prepareDatasource(dataSource)
        return dataSource
        }()
}


extension BaseProfileViewController {
    class ProfileDataSource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 100
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ListProductCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return TableViewCellTextModel(title: "\(Float(indexPath.row) / 100.0) miles")
        }
        
        override func nibCellsId() -> [String] {
            return [ListProductCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let browseController = parentViewController as? BrowseActionProducer,
                let actionConsumer = browseController.actionConsumer {
                    actionConsumer.browseController(browseController, didSelectPost: Post(objectId: CRUDObjectInvalidId))
            }
        }
    }
}