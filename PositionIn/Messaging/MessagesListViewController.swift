//
//  MessagesListViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class MessagesListViewController: BesideMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        reloadData()
    }

    func reloadData() {
        let items = mockData()
        dataSource.setItems(items)
        tableView.reloadData()
    }
    
    
    func mockData() -> [Message] {
        return [
            Message(name: "The Forest", text: "Edward Rayan Edward Rayan Edward Rayan ", imageUrl: "", date: NSDate()),
            Message(name: "The Forest", text: "Edward Rayan", imageUrl: "", date: NSDate()),
            Message(name: "The Forest", text: "Edward Rayan", imageUrl: "", date: NSDate())
        ]
    }
    

    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var dataSource: ChatHistoryDataSource = { [unowned self] in
        let dataSource = ChatHistoryDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}


extension MessagesListViewController {
    class ChatHistoryDataSource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return count(models)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return count(models[section])
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return models[indexPath.section][indexPath.row]
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            let model = self.tableView(tableView, modelForIndexPath: indexPath)
            return modelFactory.messageReuseIdForModel(model)
        }
        
        override func nibCellsId() -> [String] {
            return modelFactory.messageReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        func setItems(messages: [Message]) {
            models = messages.map { self.modelFactory.messageModelsForItem($0) }
        }
        
        
        private var models: [[MessageTableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
    }
}