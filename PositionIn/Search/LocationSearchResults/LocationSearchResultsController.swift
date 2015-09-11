//
//  LocationSearchResultsController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 11/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol LocationSearchResultStorage: class {
    func setLocations(locations: [Location])
}


class LocationSearchResultsController {
    
    init(table: TableView?, resultStorage: LocationSearchResultStorage?) {
        locationsTable = table
        self.resultStorage = resultStorage
    }
    
    func reloadData() {
        locationController().geocodeString("Times Square").onSuccess { [weak self] locations in
            Log.debug?.value(locations)
            self?.resultStorage?.setLocations(locations)
            self?.locationsTable?.reloadData()
        }.onFailure { error in
            Log.error?.value(error)
        }
    }
    
    private weak var resultStorage: LocationSearchResultStorage?
    private weak var locationsTable: TableView?
}