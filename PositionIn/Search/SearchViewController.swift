//
//  SearchViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class SearchViewController: UIViewController {
    
    class func present(searchBar: SearchBar, presenter: UIViewController) {
        let searchController = Storyboards.Main.instantiateSearchViewController()
        let transitionDelegate = SearchTransitioningDelegate()
        transitionDelegate.startView = searchBar
        searchController.transitioningDelegate = transitionDelegate
        presenter.presentViewController(searchController, animated: true) {
        }
    }
    
    enum SearchMode {
        case Items
        case Locations
    }
    
    var searchMode: SearchMode = .Items {
        didSet {
            let dataSource: TableViewDataSource
            switch searchMode {
            case .Items:
                dataSource = itemsDataSource
                //TODO add items controller reload data
                itemsSearchController.shouldReloadSearch()
            case .Locations:
                dataSource = locationsDataSource
                locationSearchController.shouldReloadSearch()
            }
            dataSource.configureTable(tableView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: "didTapOutsideSearch:")
        dismissRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(dismissRecognizer)
        
        locationSearchBar.text = SearchFilter.currentFilter.locationName
        locationsDataSource.delegate = self
        locationSearchController.delegate = self
        
        categoriesSearchBar.text = SearchFilter.currentFilter.name
        itemsDataSource.delegate = self
        itemsSearchController.delegate = self
        
        categoriesSearchBar.becomeFirstResponder()
    }
    
    func didTapOutsideSearch(sender: UIGestureRecognizer) {
        view.endEditing(true)
        transitioningDelegate = nil
        dismissViewControllerAnimated(true, completion: nil)
        Log.debug?.message("Should close search")
    }
    
    @IBOutlet private(set) weak var categoriesSearchBar: UISearchBar!
    @IBOutlet private(set) weak var locationSearchBar: UISearchBar!
    @IBOutlet private(set) weak var backImageView: UIImageView!
    
    @IBOutlet private weak var tableView: TableView!
    
    private lazy var itemsDataSource: ItemsSearchResultDataSource = { [unowned self] in
        let dataSource = ItemsSearchResultDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

    private lazy var locationsDataSource: LocationSearchResultDataSource = { [unowned self] in
        let dataSource = LocationSearchResultDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    private lazy var locationSearchController: LocationSearchResultsController = { [unowned self] in
        let controller = LocationSearchResultsController(table: self.tableView, resultStorage: self.locationsDataSource, searchBar: self.locationSearchBar)
        return controller
    }()
    
    private lazy var itemsSearchController: ItemsSearchResultsController = { [unowned self] in
        let controller = ItemsSearchResultsController(table: self.tableView, resultStorage: self.itemsDataSource, searchBar: self.categoriesSearchBar)
        return controller
        }()
}

extension SearchViewController: LocationSearchResultsDelegate {
    func shouldDisplayLocationSearchResults() {
        searchMode = .Locations
    }
    
    func didSelectLocation(location: Location?) {
        SearchFilter.setLocation(location)
    }
}

extension SearchViewController: ItemsSearchResultsDelegate {
    
    func shouldDisplayItemsSearchResults() {
        searchMode = .Items
    }
    
    func didSelectItem(item: FeedItem?) {
        
    }
}
