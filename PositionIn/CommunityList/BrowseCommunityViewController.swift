//
//  CommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import BrightFutures
import CleanroomLogger

protocol BrowseCommunityActionConsumer {
    func executeAction(action: BrowseCommunityViewController.Action, community: CRUDObjectId)
}

protocol BrowseCommunityActionProvider {
    var actionConsumer: BrowseCommunityActionConsumer? { get set }
}


final class BrowseCommunityViewController: BesideMenuViewController {
    
    enum Action: Int {
        case Browse
        case Join
        case Post
        case Invite
        case Edit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        dataSource.configureTable(tableView)
        browseMode = .MyGroups
    }
    
    var browseMode: BrowseMode = .MyGroups {
        didSet {
            browseModeSegmentedControl.selectedSegmentIndex = browseMode.rawValue
            reloadData()
        }
    }
    
    enum BrowseMode: Int {
        case MyGroups
        case Explore
    }

    func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let communitiesRequest: Future<CollectionResponse<Community>, NSError>
        let browseMode = self.browseMode
        switch browseMode {
        case .MyGroups:
            communitiesRequest = api().currentUserId().flatMap { userId in
                return api().getUserCommunities(userId)
            }
        case .Explore:
            communitiesRequest = api().getCommunities(APIService.Page())
        }
        communitiesRequest.onSuccess(token: dataRequestToken) { [weak self] response in
            if let communities = response.items {
                Log.debug?.value(communities)
                self?.dataSource.setCommunities(communities, mode: browseMode)
                self?.tableView.reloadData()
            }
        }
    }
    
    
    private lazy var dataSource: BrowseCommunityDataSource = {
        let dataSource = BrowseCommunityDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCommunityTouched(sender: AnyObject) {
        let controller = Storyboards.NewItems.instantiateAddCommunityViewController()
        navigationController?.pushViewController(controller, animated: true)
        self.subscribeForContentUpdates(controller)
    }

    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        if isViewLoaded() {
            reloadData()
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    @IBAction func browseModeSegmentChanged(sender: UISegmentedControl) {
        if let mode = BrowseMode(rawValue: sender.selectedSegmentIndex) {
            browseMode = mode
        }
    }
    
    @IBOutlet private weak var browseModeSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var tableView: TableView!
    
    private var dataRequestToken = InvalidationToken()
}

extension BrowseCommunityViewController {
    internal class BrowseCommunityDataSource: TableViewDataSource {
        
        var actionConsumer: BrowseCommunityActionConsumer? {
            return parentViewController as? BrowseCommunityActionConsumer
        }
        
        private var items: [[TableViewCellModel]] = []
        private let cellFactory = BrowseCommunityCellFactory()
        
        func setCommunities(communities: [Community], mode: BrowseCommunityViewController.BrowseMode) {
            items = communities.map { self.cellFactory.modelsForCommunity($0, mode: mode) }
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return cellFactory.cellReuseIdForModel(self.tableView(tableView, modelForIndexPath: indexPath))
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }

        
        override func nibCellsId() -> [String] {
            return cellFactory.communityCellsReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
        }
    }
}

extension BrowseCommunityViewController: BrowseCommunityActionConsumer {
    func executeAction(action: BrowseCommunityViewController.Action, community: CRUDObjectId) {
        
    }
   
}