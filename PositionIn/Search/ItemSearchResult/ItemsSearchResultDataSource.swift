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
    func setItems(feedItems:  [TableViewCellModel]) {
        itemModels = feedItems
    }
    
    override func configureTable(tableView: UITableView) {
        tableView.estimatedRowHeight = 50.0
        tableView.keyboardDismissMode = .OnDrag
        super.configureTable(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels.count
    }
    
    override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        return self.itemModels[indexPath.row]
    }
    
    @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        let model = self.tableView(tableView, modelForIndexPath: indexPath)
        
        switch model {
        case _ as SearchSectionCellModel:
            return SearchSectionCell.reuseId()
        case _ as SearchItemCellModel:
            return SearchEntityCell.reuseId()
        default:
            break
        }
        
        return TableViewCell.reuseId()
    }
    
    override func nibCellsId() -> [String] {
        return [SearchEntityCell.reuseId(), SearchSectionCell.reuseId()]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = self.tableView(tableView, modelForIndexPath: indexPath)
        self.delegate?.didSelectModel(model)
    }
    
    weak var delegate: ItemsSearchResultsDelegate?
    private var itemModels: [TableViewCellModel] = []
}