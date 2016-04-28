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

class PeopleFollowingViewController : UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: TableView!
    @IBOutlet private weak var noFollowersWarningLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        dataSource.configureTable(tableView)
        subscribeToNotifications()
        
        reloadData()
        
        let gesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func viewTapped() {
        view.endEditing(true)
    }
    
    func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let peopleRequest: Future<CollectionResponse<UserInfo>,NSError>
        
        let mySubscriptionsRequest = api().getMySubscriptions(searchBar.text)
        if firstFollowingRequestToken.isInvalid {
            peopleRequest = mySubscriptionsRequest
        } else {
            // On first load switch to explore if not following any user
            firstFollowingRequestToken.invalidate()
            peopleRequest = mySubscriptionsRequest.flatMap { [weak self] response -> Future<CollectionResponse<UserInfo>,NSError> in
                if let userList = response.items  where userList.count == 0 {
                    let parentViewController = self?.parentViewController as? PeopleContainerViewController
                    parentViewController?.switchToExploreViewController()
                }
                
                return Future(value: response)
            }
        }
    
        peopleRequest.onSuccess(dataRequestToken.validContext) { [weak self] response in
            if let userList = response.items {
                Log.debug?.value(userList)

                self?.tableView.hidden = userList.count == 0
                self?.noFollowersWarningLabel.hidden = !(userList.count == 0)
               
                self?.dataSource.setUserList(userList)
                self?.tableView.reloadData()
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 || searchText.characters.count == 0 {
            NSObject.cancelPreviousPerformRequestsWithTarget(self)
            self.performSelector("reloadData", withObject: nil, afterDelay: 2.0)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.performSelector("reloadData")
        searchBar.resignFirstResponder()
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
    
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return searchBar.isFirstResponder()
    }
    
}

final class PeopleFollowingDataSource: TableViewDataSource {
    private var items: [UserInfoTableViewCellModel] = []
    
    func setUserList(users: [UserInfo]) {
        items = users.sort{ ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == NSComparisonResult.OrderedAscending }.map{ UserInfoTableViewCellModel(userInfo: $0) }
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