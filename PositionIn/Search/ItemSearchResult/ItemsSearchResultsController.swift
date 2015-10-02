//
//  ItemSearchResultsController.swift
//  PositionIn
//
//  Created by mpol on 10/1/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger
import BrightFutures

protocol ItemsSearchResultStorage: class {
    func setItems(feedItems: [[FeedItem]])
}

protocol ItemsSearchResultsDelegate: class {
    func shouldDisplayItemsSearchResults()
    func didSelectItem(item: FeedItem?)
}

class ItemsSearchResultsController: NSObject {
    
    private var filter = SearchFilter.currentFilter
    
    init(table: TableView?, resultStorage: ItemsSearchResultStorage?, searchBar: UISearchBar?) {
        itemsTable = table
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
        let completion: ([[FeedItem]]) -> Void = { [weak self] items in
            Log.debug?.value(items)
            self?.resultStorage?.setItems(items)
            self?.itemsTable?.reloadData()
        }
        let searchString = map(searchBar?.text) { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        if let searchString = searchString where count(searchString) > 0 {
            
            let completion: ([[FeedItem]]) -> Void = { [weak self] items in
                Log.debug?.value(items)
                self?.resultStorage?.setItems(items)
                self?.itemsTable?.reloadData()
            }
            
            Log.info?.message("Search string: \(searchString)")
            var f = filter
            f.name = searchString
            api().getSearchFeed(f, page: APIService.Page()).onSuccess(token: dataRequestToken) {
                [weak self] response in
                Log.debug?.value(response.items)
                completion([response.promotions, response.communities, response.items, response.events, response.peoples])
            }
        } else {
            delegate?.didSelectItem(nil)
            completion([])
        }
    }
    
    deinit {
        searchTimer?.invalidate()
    }
    
    weak var delegate: ItemsSearchResultsDelegate?
    private weak var resultStorage: ItemsSearchResultStorage?
    private weak var itemsTable: TableView?
    private weak var searchBar: UISearchBar?
    private var dataRequestToken = InvalidationToken()
    private var searchTimer: NSTimer?
    
    let searchDelay: NSTimeInterval = 1.5
}

extension ItemsSearchResultsController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        shouldReloadSearch()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        shouldReloadSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        delegate?.shouldDisplayItemsSearchResults()
    }
}