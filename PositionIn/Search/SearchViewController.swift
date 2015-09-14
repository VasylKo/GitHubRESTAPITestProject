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
            case .Locations:
                dataSource = locationsDataSource
            }
            dataSource.configureTable(tableView)
            locationSearchController.shouldReloadSearch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissRecognizer = UITapGestureRecognizer(target: self, action: "didTapOutsideSearch:")
        dismissRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissRecognizer)
        
        locationSearchController.delegate = self
        
        locationSearchBar.becomeFirstResponder()
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
    
}

extension SearchViewController: LocationSearchResultsDelegate {
    func shouldDisplayLocationSearchResults() {
        searchMode = .Locations
    }
}

extension SearchViewController {
    class ItemsSearchResultDataSource: TableViewDataSource {
        
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
            return modelFactory.compactCellReuseIdForModel(model)
        }
        
        override func nibCellsId() -> [String] {
            return modelFactory.compactCellsReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        private var models: [[TableViewCellModel]] = []
        private let modelFactory = FeedItemCellModelFactory()
    }
}

