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
    func didSelectLocation(location: Location?)
}

final class LocationSearchResultsController: NSObject {
        
    init(table: TableView?, resultStorage: LocationSearchResultStorage?, searchBar: UITextField?) {
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
            self?.locationsTable?.scrollEnabled = self?.locationsTable?.frame.size.height < self?.locationsTable?.contentSize.height
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
            delegate?.didSelectLocation(nil)
            completion([])
        }
    }
    
    deinit {
        searchTimer?.invalidate()
    }


    weak var delegate: LocationSearchResultsDelegate? 
    private weak var resultStorage: LocationSearchResultStorage?
    private weak var locationsTable: TableView?
    private weak var searchBar: UITextField?
    private var dataRequestToken = InvalidationToken()
    private var searchTimer: NSTimer?
    
    let searchDelay: NSTimeInterval = 1.5
}

extension LocationSearchResultsController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        shouldReloadSearch()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.bt_colorWithBytesR(0, g: 0, b: 0, a: 102)
        textField.textColor = UIColor.blackColor()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.bt_colorWithBytesR(255, g: 255, b: 255, a: 255)
        textField.textColor = UIColor.blackColor()
        delegate?.shouldDisplayLocationSearchResults()
    }
}