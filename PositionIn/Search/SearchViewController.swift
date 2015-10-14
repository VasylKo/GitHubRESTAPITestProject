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

protocol SearchViewControllerDelegate: class  {   
    func searchViewControllerItemSelected(model: SearchItemCellModel?)
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?)
}

final class SearchViewController: UIViewController {
    
    class func present<T: UIViewController where T: SearchViewControllerDelegate>(searchBar: UITextField, presenter: T) {
        let searchController = Storyboards.Main.instantiateSearchViewController()
        let transitionDelegate = SearchTransitioningDelegate()
        transitionDelegate.startView = searchBar
        searchController.transitioningDelegate = transitionDelegate
        searchController.delegate = presenter
        presenter.presentViewController(searchController, animated: true) {
        }
    }
    
    enum SearchMode {
        case Items
        case Locations
    }
    
    weak var delegate: SearchViewControllerDelegate?
    
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
        
        searchTextField.leftView = UIImageView(image: UIImage(named: "search_icon"))
        searchTextField.leftViewMode = .Always
        searchTextField.text = SearchFilter.currentFilter.name
        searchTextField.becomeFirstResponder()
        itemsDataSource.delegate = self
        itemsSearchController.delegate = self

        locationSearchTextField.text = SearchFilter.currentFilter.locationName
        locationsDataSource.delegate = self
        locationSearchController.delegate = self
        locationSearchTextField.leftView = UIImageView(image: UIImage(named: "search_icon"))
        locationSearchTextField.leftViewMode = .Always


    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.shouldCloseSearch()
    }
    
    func didTapOutsideSearch(sender: UIGestureRecognizer) {
        self.shouldCloseSearch()
    }
    
    func shouldCloseSearch() {
        view.endEditing(true)
        transitioningDelegate = nil
        dismissViewControllerAnimated(true, completion: nil)
        Log.debug?.message("Should close search")
    }
    
    @IBOutlet private(set) weak var backImageView: UIImageView!
    @IBOutlet private(set) weak var searchTextField: UITextField!
    @IBOutlet private(set) weak var locationSearchTextField: UITextField!
    
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
        let controller = LocationSearchResultsController(table: self.tableView, resultStorage: self.locationsDataSource, searchBar: self.locationSearchTextField)
        return controller
    }()
    
    private lazy var itemsSearchController: ItemsSearchResultsController = { [unowned self] in
        let controller = ItemsSearchResultsController(table: self.tableView, resultStorage: self.itemsDataSource, searchBar: self.searchTextField)
        return controller
        }()
}

extension SearchViewController: LocationSearchResultsDelegate {
    func shouldDisplayLocationSearchResults() {
        searchMode = .Locations
    }
    
    func didSelectLocation(location: Location?) {
        SearchFilter.setLocation(location)
        self.shouldCloseSearch()
    }
}

extension SearchViewController: ItemsSearchResultsDelegate {
    
    func shouldDisplayItemsSearchResults() {
        searchMode = .Items
    }
    
    func didSelectModel(model: TableViewCellModel?) {
        self.shouldCloseSearch()

        switch model {
        case let sectionModel as SearchSectionCellModel:
            self.delegate?.searchViewControllerSectionSelected(sectionModel)
        case let itemModel as SearchItemCellModel:
            self.delegate?.searchViewControllerItemSelected(itemModel)
        default:
            break
        }
    }
}
