//
//  BaseProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger

class ProfileListViewController: BesideMenuViewController, BrowseActionProducer {
    
    weak var actionConsumer: BrowseActionConsumer?

    enum Sections: Int {
        case Info, Feed
    }
    
    var profile: UserProfile = UserProfile(objectId: CRUDObjectInvalidId) {
        didSet {
            if isViewLoaded() {
                didReceiveProfile(profile)
            }
        }
    }

    //MARK: - Reload data -
    
    func reloadData() {
        api().getUserProfile(profile.objectId).zip(api().getSubscriptionStateForUser(profile.objectId)).onSuccess {
            [weak self] profile, state in
            self?.didReceiveProfile(profile, state: state)
        }
    }
    
    
    private func didReceiveProfile(profile: UserProfile, state: UserProfile.SubscriptionState = .SameUser) {
        let isCurrentUser = api().isCurrentUser(profile.objectId)
        let isUserAuthorized = api().isUserAuthorized()
        let (leftAction, rightAction): (UserProfileViewController.ProfileAction, UserProfileViewController.ProfileAction) = {
            switch(isCurrentUser, isUserAuthorized) {
            case (true, _):
                return (.None, .Edit)
            case (_, true):
                return (.Call, .Chat)
            default:
                return (.None, .None)
            }
        }()
        let actionDelegate = self.parentViewController as? UserProfileActionConsumer
        var infoSection: [ProfileCellModel] = [
            ProfileInfoCellModel(name: profile.displayName, avatar: profile.avatar, background: profile.backgroundImage, leftAction: leftAction, rightAction: rightAction, actionDelegate: actionDelegate),
            TableViewCellTextModel(title: profile.userDescription ?? ""),
            ProfileStatsCellModel(countPosts: profile.countPosts, countFollowers: profile.countFollowers, countFollowing: profile.countFollowing),
        ]
        switch state {
        case .SameUser:
            break
        default:
            infoSection.append(ProfileFollowCellModel(state: state, actionDelegate: actionDelegate))
            break
        }
        dataSource.items[Sections.Info.rawValue] = infoSection
        
        var feedModel = BrowseListCellModel(objectId: profile.objectId, actionConsumer: self)
        feedModel.excludeCommunityItems = true
        dataSource.items[Sections.Feed.rawValue] = [ feedModel ]
        
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
        didReceiveProfile(profile)
        reloadData()
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    
    lazy var dataSource: ProfileDataSource = {
        let dataSource = ProfileDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
}

extension ProfileListViewController: BrowseActionConsumer {
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


protocol ProfileCellModel: TableViewCellModel {
}


extension TableViewCellTextModel: ProfileCellModel {
    
}

extension ProfileListViewController {
    final class ProfileDataSource: TableViewDataSource {
        var items: [[ProfileCellModel]] = [[],[]]
        
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
            case let model as ProfileInfoCellModel:
                return ProfileInfoCell.reuseId()
            case let model as ProfileStatsCellModel:
                return ProfileStatsCell.reuseId()
            case let model as BrowseListCellModel:
                return BrowseListTableViewCell.reuseId()
            case let model as TableViewCellTextModel:
                return DescriptionTableViewCell.reuseId()
            case let model as ProfileFollowCellModel:
                return ProfileFollowCell.reuseId()
            default:
                return super.tableView(tableView, reuseIdentifierForIndexPath: indexPath)
            }
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return [ProfileInfoCell.reuseId(), ProfileStatsCell.reuseId(), BrowseListTableViewCell.reuseId(), DescriptionTableViewCell.reuseId(), ProfileFollowCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        @objc override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? TableViewCellTextModel
               where count(model.title) == 0 {
                return 0.0
            }
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}