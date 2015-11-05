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
        
        let str = NSAttributedString(string: self.searchBar!.placeholder!,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        self.searchBar!.attributedPlaceholder = str
        
        searchBar?.delegate = self
    }

    func shouldReloadSearch() {
        searchTimer?.invalidate()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(searchDelay, target: self, selector: "reloadSearch", userInfo: nil, repeats: false)
    }
    
    func reloadSearch() {
        guard let searchBar = searchBar else {
            return
        }
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let completion: ([Location]) -> Void = { [weak self] locations in
            Log.debug?.value(locations)
            self?.resultStorage?.setLocations(locations)
            self?.locationsTable?.reloadData()
            self?.locationsTable?.scrollEnabled = self?.locationsTable?.frame.size.height < self?.locationsTable?.contentSize.height
        }
        
        let searchString = searchBar.text.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        if let searchString = searchString where searchString.characters.count > 0 {
            Log.info?.message("Geocoding location: \(searchString)")
            locationController().geocodeString(searchString).onSuccess(dataRequestToken.validContext, callback: completion).onFailure { error in
                    Log.error?.value(error)
            }
        }
        else {
            locationController().getCurrentLocation().onSuccess(dataRequestToken.validContext, callback: { [weak self] location in
                self?.resultStorage?.setLocations([Location.currentLocation])
                self?.locationsTable?.reloadData()
                self?.locationsTable?.scrollEnabled = self?.locationsTable?.frame.size.height < self?.locationsTable?.contentSize.height
            })
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
        let str = NSAttributedString(string: textField.placeholder!,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        textField.attributedPlaceholder = str
        textField.textColor = UIColor.whiteColor()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.bt_colorWithBytesR(255, g: 255, b: 255, a: 255)
        let str = NSAttributedString(string: textField.placeholder!,
            attributes: [NSForegroundColorAttributeName:UIColor(white: 201/255, alpha: 1)])
        textField.attributedPlaceholder = str
        textField.textColor = UIColor.blackColor()
        delegate?.shouldDisplayLocationSearchResults()
    }
}