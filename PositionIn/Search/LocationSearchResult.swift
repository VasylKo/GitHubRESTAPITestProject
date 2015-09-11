//
//  LocationSearchResult.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 11/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore


class LocationSearchResultDataSource: TableViewDataSource {
    
    func setLocations(locations: [Location]) {
        locationModels = locations.map { location in
            return LocationCellModel(title: location.name ?? "", coordinate: location.coordinates)
        }
    }
    
    override func configureTable(tableView: UITableView) {
        tableView.estimatedRowHeight = 50.0
        super.configureTable(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(locationModels)
    }
    
    override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        return locationModels[indexPath.row]
    }
    
    @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        let model = self.tableView(tableView, modelForIndexPath: indexPath)
        return LocationCell.reuseId()
    }
    
    override func nibCellsId() -> [String] {
        return [ LocationCell.reuseId() ]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private var locationModels: [TableViewCellModel] = []
}