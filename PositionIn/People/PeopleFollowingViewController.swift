//
//  SubscriptionsViewController.swift
//  PositionIn
//
//  Created by ng on 3/22/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import BrightFutures
import CleanroomLogger

class PeopleFollowingViewController : UIViewController {
    
    @IBOutlet private weak var tableView: TableView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        dataSource.configureTable(tableView)
        subscribeToNotifications()
        
        reloadData()
    }
    
    func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let peopleRequest: Future<CollectionResponse<UserInfo>,NSError>
        
        let mySubscriptionsRequest = api().getMySubscriptions()
        if firstFollowingRequestToken.isInvalid {
            peopleRequest = mySubscriptionsRequest
        } else {
            // On first load switch to explore if not following any user
            firstFollowingRequestToken.invalidate()
            peopleRequest = mySubscriptionsRequest.flatMap { response -> Future<CollectionResponse<UserInfo>,NSError> in
                if let userList = response.items  where userList.count == 0 {
                    return Future(error: NetworkDataProvider.ErrorCodes.InvalidRequestError.error())
                } else {
                    return Future(value: response)
                }
            }
        }
    
        peopleRequest.onSuccess(dataRequestToken.validContext) { [weak self] response in
            if let userList = response.items {
                Log.debug?.value(userList)
                self?.dataSource.setUserList(userList)
                self?.tableView.reloadData()
            }
        }
    }
    
    private func subscribeToNotifications() {
        subscriptionUpdateObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfileViewController.SubscriptionDidChangeNotification,
            object: nil,
            queue: nil) { [weak self] (_: NSNotification!) -> Void in
                if let viewLoaded = self?.isViewLoaded() where viewLoaded == true {
                    self?.reloadData()
                }
        }
    }
    
    deinit {
        if let subscriptionUpdateObserver = self.subscriptionUpdateObserver {
            NSNotificationCenter.defaultCenter().removeObserver(subscriptionUpdateObserver)
        }
    }
    
    private var subscriptionUpdateObserver: NSObjectProtocol?

    func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        (self.parentViewController as? BesideMenuViewController)?.contentDidChange(sender, info: info)
        if isViewLoaded() {
            reloadData()
        }
    }
    
    private var dataRequestToken = InvalidationToken()
    private let firstFollowingRequestToken = InvalidationToken()
    
    private lazy var dataSource: PeopleFollowingDataSource = { [unowned self] in
        let dataSource = PeopleFollowingDataSource()
        dataSource.parentViewController = self.parentViewController
        return dataSource
        }()
    
}

final class PeopleFollowingDataSource: TableViewDataSource {
    private var items: [UserInfoTableViewCellModel] = []
    
    func setUserList(users: [UserInfo]) {
        items = users.sort{ $0.title < $1.title }.map{ UserInfoTableViewCellModel(userInfo: $0) }
    }
    
    override func configureTable(tableView: UITableView) {
        tableView.estimatedRowHeight = 60.0
        super.configureTable(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        return PeopleListCell.reuseId()
    }
    
    override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        return items[indexPath.row]
    }
    
    override func nibCellsId() -> [String] {
        return [ PeopleListCell.reuseId() ]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? UserInfoTableViewCellModel,
            let parentViewController = parentViewController as? PeopleActionConsumer {
                parentViewController.showProfileScreen(model.userInfo.objectId)
        }
    }
    
}