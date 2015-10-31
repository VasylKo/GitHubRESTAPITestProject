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
    func searchViewControllerCancelSearch()
    func searchViewControllerItemSelected(model: SearchItemCellModel?, searchString: String?, locationString: String?)
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?, searchString: String?, locationString: String?)
    func searchViewControllerLocationSelected(locationString: String?)
}

final class SearchViewController: UIViewController {
    
    class func present<T: UIViewController where T: SearchViewControllerDelegate>(searchBar: UITextField, presenter: T, filter: SearchFilter) {
        let searchController = Storyboards.Main.instantiateSearchViewController()
        let transitionDelegate = SearchTransitioningDelegate()
        transitionDelegate.startView = searchBar
        searchController.transitioningDelegate = transitionDelegate
        searchController.delegate = presenter
        searchController.filter = filter
        presenter.presentViewController(searchController, animated: true) {
        }
    }
    
    enum SearchMode {
        case Items
        case Locations
    }
    
    weak var delegate: SearchViewControllerDelegate?
    var filter: SearchFilter = SearchFilter.currentFilter
    
    var searchMode: SearchMode = .Items {
        didSet {
            let dataSource: TableViewDataSource
            switch searchMode {
            case .Items:
                dataSource = itemsDataSource
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
        
        searchTextField.leftViewMode = .Always
        let leftView: UIImageView = UIImageView(image: UIImage(named: "search_icon"))
        leftView.frame = CGRectMake(0.0, 0.0, leftView.frame.size.width + 5.0, leftView.frame.size.height);
        leftView.contentMode = .Center
        searchTextField.leftView = leftView
        searchTextField.text = SearchFilter.currentFilter.name
        searchTextField.becomeFirstResponder()
        itemsDataSource.delegate = self
        itemsSearchController.delegate = self

        locationSearchTextField.text = SearchFilter.currentFilter.locationName
        locationsDataSource.delegate = self
        locationSearchController.delegate = self
        let leftLocationView: UIImageView = UIImageView(image: UIImage(named: "search_location_focus"))
        leftLocationView.frame = CGRectMake(0.0, 0.0, leftLocationView.frame.size.width + 5.0, leftView.frame.size.height);
        leftLocationView.contentMode = .Center
        locationSearchTextField.leftView = leftLocationView
        locationSearchTextField.leftViewMode = .Always
        locationSearchTextField.backgroundColor = UIColor.bt_colorWithBytesR(0, g: 0, b: 0, a: 102)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.shouldCloseSearch()
        self.delegate?.searchViewControllerCancelSearch()
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
        controller.filter = self.filter
        return controller
        }()
}

extension SearchViewController: LocationSearchResultsDelegate {
    func shouldDisplayLocationSearchResults() {
        searchMode = .Locations
    }
    
    func didSelectLocation(location: Location?) {
        SearchFilter.setLocation(location)
        locationSearchTextField.text =  SearchFilter.currentFilter.locationName
        self.delegate?.searchViewControllerLocationSelected(SearchFilter.currentFilter.locationName)
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
            self.delegate?.searchViewControllerSectionSelected(sectionModel, searchString: searchTextField.text,
                locationString: self.locationSearchTextField.text)
        case let itemModel as SearchItemCellModel:
            self.delegate?.searchViewControllerItemSelected(itemModel, searchString: searchTextField.text,
                locationString: self.locationSearchTextField.text)
        default:
            break
        }
    }
}
