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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapOutsideSearch:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBOutlet private weak var tableView: UITableView!
    private lazy var dataSource: SearchResultDataSource = {
        let dataSource = SearchResultDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
}

extension SearchViewController {
    internal class SearchResultDataSource: TableViewDataSource {
        
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