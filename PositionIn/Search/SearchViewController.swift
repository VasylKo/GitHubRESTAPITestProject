//
//  SearchViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {

    @IBOutlet private(set) weak var categoriesSearchBar: UISearchBar!
    @IBOutlet private(set) weak var locationSearchBar: UISearchBar!
    @IBOutlet private(set) weak var tableView: UITableView!
    
    @IBOutlet private(set) weak var backImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        categoriesSearchBar.becomeFirstResponder()
    }
    
    class func present(searchBar: SearchBar, presenter: UIViewController) {
        let searchController = Storyboards.Main.instantiateSearchViewController()
        let transitionDelegate = SearchTransitioningDelegate()
        transitionDelegate.startView = searchBar
        searchController.transitioningDelegate = transitionDelegate
        presenter.presentViewController(searchController, animated: true) {            
        }
    }
}
