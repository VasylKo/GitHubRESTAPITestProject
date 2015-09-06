//
//  CommunityFeedViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger

class CommunityFeedViewController: BesideMenuViewController, BrowseActionProducer {
    
    weak var actionConsumer: BrowseActionConsumer?

    enum Sections: Int {
        case Info, Feed
    }
    
    var community: Community = Community(objectId: CRUDObjectInvalidId) {
        didSet {
            if isViewLoaded() {
                didReceiveCommunity(community)
            }
        }
    }

    //MARK: - Reload data -
    
    func reloadData() {
        api().getCommunity(community.objectId).onSuccess { [weak self] community in
            self?.didReceiveCommunity(community)
        }
        
    }
    
    
    private func didReceiveCommunity(community: Community) {

        let actionDelegate = self.parentViewController as? BrowseActionConsumer
        dataSource.items[Sections.Info.rawValue] = [
            BrowseCommunityHeaderCellModel(objectId: community.objectId, tapAction: .None, title: community.name ?? "", url: community.avatar),
            ProfileStatsCellModel(countPosts: 0, countFollowers: 0, countFollowing: 0)
        ]
        dataSource.items[Sections.Feed.rawValue] = [
            BrowseListCellModel(objectId: community.objectId, actionConsumer: self, filterType: .Community)
        ]
        tableView.reloadData()
        actionConsumer?.browseControllerDidChangeContent(self)
    }

    
    //MARK: - Table -
    @IBOutlet private weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        dataSource.configureTable(tableView)
       // didReceiveCommunity(community)
        reloadData()
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    
    lazy var dataSource: CommunityFeedDataSource = {
        let dataSource = CommunityFeedDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
}

extension CommunityFeedViewController: BrowseActionConsumer {
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType, data: Any?) {
        actionConsumer?.browseController(controller, didSelectItem: objectId, type: itemType, data: data)
    }
    
    func browseControllerDidChangeContent(controller: BrowseActionProducer) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        actionConsumer?.browseControllerDidChangeContent(controller)
    }
}



extension CommunityFeedViewController {
    final class CommunityFeedDataSource: TableViewDataSource {
        var items: [[TableViewCellModel]] = [[],[]]
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return count(items)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return count(items[section])
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            let model = self.tableView(tableView, modelForIndexPath: indexPath)
            switch model {
            case let model as BrowseCommunityHeaderCellModel:
                return CommunityHeaderCell.reuseId()
            case let model as ProfileStatsCellModel:
                return ProfileStatsCell.reuseId()
            case let model as BrowseListCellModel:
                return BrowseListTableViewCell.reuseId()
            default:
                return super.tableView(tableView, reuseIdentifierForIndexPath: indexPath)
            }
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
       return [CommunityHeaderCell.reuseId(), ProfileStatsCell.reuseId(), BrowseListTableViewCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
}