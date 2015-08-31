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

class ProfileListViewController: BesideMenuViewController {
    //MARK: - Reload data -
    
    var profile: UserProfile = UserProfile(objectId: CRUDObjectInvalidId) {
        didSet {
            if isViewLoaded() {
                didReceiveProfile(profile)
            }
        }
    }
    
    func reloadData() {
        let page = APIService.Page()
        api().getUserProfile(profile.objectId).onSuccess { [weak self] profile in
            self?.didReceiveProfile(profile)
        }
            
    }
    
    
    private func didReceiveProfile(profile: UserProfile) {
        let (leftAction, rightAction): (UserProfileViewController.ProfileAction, UserProfileViewController.ProfileAction) = {
            if let currentUserId = api().currentUserId() where currentUserId == profile.objectId {
                return (.None, .Edit)
            } else {
                return (.Call, .Chat)
            }
        }()
        let actionDelegate = self.parentViewController as? UserProfileActionConsumer
        dataSource.items[0] = [
            ProfileInfoCellModel(name: profile.firstName, avatar: profile.avatar, background: profile.backgroundImage, leftAction: leftAction, rightAction: rightAction, actionDelegate: actionDelegate),
            ProfileStatsCellModel(countPosts: 113, countFollowers: 23, countFollowing: 2),
        ]
        dataSource.items[1] = [
            BrowseListCellModel(objectId: profile.objectId)
        ]
        tableView.reloadData()
    }

    
    //MARK: - Table -
    @IBOutlet weak var tableView: TableView!
    
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


protocol ProfileCellModel: TableViewCellModel {
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
            default:
                return super.tableView(tableView, reuseIdentifierForIndexPath: indexPath)
            }
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return [ProfileInfoCell.reuseId(), ProfileStatsCell.reuseId(), BrowseListTableViewCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

        }
    }
}