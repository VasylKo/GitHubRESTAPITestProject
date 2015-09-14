//
//  LocationSearchResultsController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 11/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger
import BrightFutures


protocol LocationSearchResultStorage: class {
    func setLocations(locations: [Location])
}

protocol LocationSearchResultsDelegate: class {
    func shouldDisplayLocationSearchResults()
}

final class LocationSearchResultsController: NSObject {
    
    init(table: TableView?, resultStorage: LocationSearchResultStorage?, searchBar: UISearchBar?) {
        locationsTable = table
        self.resultStorage = resultStorage
        self.searchBar = searchBar
        super.init()
        searchBar?.delegate = self
    }

    func shouldReloadSearch() {
        searchTimer?.invalidate()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(searchDelay, target: self, selector: "reloadSearch", userInfo: nil, repeats: false)
    }
    
    func reloadSearch() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let completion: ([Location]) -> Void = { [weak self] locations in
            Log.debug?.value(locations)
            self?.resultStorage?.setLocations(locations)
            self?.locationsTable?.reloadData()
        }
        let searchString = map(searchBar?.text) { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        if let searchString = searchString where count(searchString) > 0 {
            Log.info?.message("Geocoding location: \(searchString)")
            locationController().geocodeString(searchString).onSuccess(
                token: dataRequestToken,
                callback: completion).onFailure { error in
                    Log.error?.value(error)
            }
        } else {
            completion([])
        }
    }
    
    deinit {
        searchTimer?.invalidate()
    }


    weak var delegate: LocationSearchResultsDelegate? 
    private weak var resultStorage: LocationSearchResultStorage?
    private weak var locationsTable: TableView?
    private weak var searchBar: UISearchBar?
    private var dataRequestToken = InvalidationToken()
    private var searchTimer: NSTimer?
    
    let searchDelay: NSTimeInterval = 1.5
}

extension LocationSearchResultsController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        shouldReloadSearch()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        shouldReloadSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        delegate?.shouldDisplayLocationSearchResults()
    }
}