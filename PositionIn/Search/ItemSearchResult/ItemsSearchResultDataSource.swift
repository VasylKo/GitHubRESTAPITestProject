//
//  ItemSearchResultDataSource.swift
//  PositionIn
//
//  Created by mpol on 10/1/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

class ItemsSearchResultDataSource: TableViewDataSource, ItemsSearchResultStorage {
    func setItems(feedItems: [[FeedItem]]) {
        itemModels = feedItems
        
    }
    
    override func configureTable(tableView: UITableView) {
        tableView.estimatedRowHeight = 50.0
        super.configureTable(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemModels.count
    }
    
    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels[section].count
    }
    
    override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        let feedItem = self.itemModels[indexPath.section][indexPath.row]
        
        return CompactFeedTableCellModel(itemType: feedItem.type, objectID: feedItem.objectId, title: feedItem.text, details: feedItem.details, info: "", imageURL: feedItem.image, data: nil)
    }
    
    @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        let model = self.tableView(tableView, modelForIndexPath: indexPath)
        //TODO: change to correct type
        return EventListCell.reuseId()
    }
    
    override func nibCellsId() -> [String] {
        return [ EventListCell.reuseId() ]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? LocationCellModel {

        }
    }
    
    weak var delegate: ItemsSearchResultsDelegate?
    private var itemModels: [[FeedItem]] = []
}

