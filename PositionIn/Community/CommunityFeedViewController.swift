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


protocol CommunityFeedActionConsumer: class {
    func communityFeedInfoTapped()
}

class CommunityFeedViewController: BesideMenuViewController, BrowseActionProducer, BrowseModeDisplay, UpdateFilterProtocol, CommunityFeedActionConsumer {
    
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
    
    var controllerType: CommunityViewController.ControllerType = .Unknown
    
    var childFilterUpdate: SearchFilterUpdate?
    
    func applyFilterUpdate(update: SearchFilterUpdate) {
        childFilterUpdate = update
    }
    
    var browseMode: BrowseModeTabbarViewController.BrowseMode = .ForYou
    
    //MARK: - Reload data -
    
    func reloadData() {
        api().getCommunity(community.objectId).onSuccess { [weak self] community in
            self?.community = community
        }
    }
    
    private func didReceiveCommunity(community: Community) {
        let headerModel = BrowseCommunityHeaderCellModel(objectId: community.objectId, tapAction: .None, title:community.name ?? "", url:community.avatar, showInfo: true)
        headerModel.actionConsumer = self
        dataSource.items[Sections.Info.rawValue] = [headerModel,
            CommunityStatsCellModel(countMembers: community.membersCount, countPosts: community.postsCount, countEvents: community.eventsCount)
        ]
        self.updateFeed()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let volunteerDetailsViewController = segue.destinationViewController  as? VolunteerDetailsViewController {
            volunteerDetailsViewController.objectId = self.community.objectId
            if let owners = (self.community.members?.items.filter(){$0.role == Community.Role.Owner.rawValue}) {
                volunteerDetailsViewController.author = owners.first
            }
//            volunteerDetailsViewController.joinAction = true/false
            if let typeValue = VolunteerDetailsViewController.ControllerType(rawValue:self.controllerType.rawValue){
                volunteerDetailsViewController.type = typeValue
            }
        }
    }

    func updateFeed() {
        var model: BrowseListCellModel = BrowseListCellModel(objectId: community.objectId, actionConsumer: self, browseMode: browseMode,
            filterType: .Community)
        model.childFilterUpdate = childFilterUpdate
        dataSource.items[Sections.Feed.rawValue] = [model]
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
        reloadData()
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    lazy var dataSource: CommunityFeedDataSource = { [unowned self] in
        let dataSource = CommunityFeedDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    func communityFeedInfoTapped() {
        self.performSegue(CommunityFeedViewController.Segue.showVolunteerDetailsViewController)
    }
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
            return (items).count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            let model = self.tableView(tableView, modelForIndexPath: indexPath)
            switch model {
            case _ as BrowseCommunityHeaderCellModel:
                return CommunityHeaderCell.reuseId()
            case _ as CommunityStatsCellModel:
                return CommunityStatsCell.reuseId()
            case _ as BrowseListCellModel:
                return BrowseListTableViewCell.reuseId()
            default:
                return super.tableView(tableView, reuseIdentifierForIndexPath: indexPath)
            }
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
       return [CommunityHeaderCell.reuseId(), CommunityStatsCell.reuseId(), BrowseListTableViewCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}