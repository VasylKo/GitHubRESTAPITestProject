//
//  PostViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures


final class PostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        if let objectId = objectId {
            api().getPost(objectId).onSuccess { [weak self] post in
                self?.dataSource.setPost(post)
                self?.tableView.reloadData()
            }
        }
    }
    
    private lazy var dataSource: PostDataSource = {
        let dataSource = PostDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

    
    @IBOutlet weak var tableView: TableView!
    var objectId: CRUDObjectId?
}


extension PostViewController {
    internal class PostDataSource: TableViewDataSource {
        private let cellFactory = PostCellModelFactory()
        private var items: [[TableViewCellModel]] = []
        
        func setPost(post: Post) {
            items = [cellFactory.modelsForPost(post)]
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return cellFactory.cellReuseIdForModel(self.tableView(tableView, modelForIndexPath: indexPath))
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return cellFactory.postCellsReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}