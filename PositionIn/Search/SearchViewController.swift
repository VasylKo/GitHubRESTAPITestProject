//
//  SearchViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        categoriesSearchBar.becomeFirstResponder()
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
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ProductListCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return TableViewCellTextModel(title: "\(Float(indexPath.row) / 100.0) miles")
        }
        
        override func nibCellsId() -> [String] {
            return [ProductListCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}