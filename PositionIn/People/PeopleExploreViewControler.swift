//
//  ExploreViewControler.swift
//  PositionIn
//
//  Created by ng on 3/22/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import BrightFutures
import CleanroomLogger

class PeopleExploreViewController : UIViewController, FetchViewLogicDelegate, UITableViewDelegate {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private weak var tableView: TableView!
    private var refreshControl : UIRefreshControl?
    
    private var viewLogic = FetchViewLogic<UserInfo, ExploreUserFetcher, PeopleExploreViewController>(with: ExploreUserFetcher(), limit: 25)
    
    private lazy var dataSource: PeopleExploreDataSource = { [unowned self] in
        let dataSource = PeopleExploreDataSource()
        dataSource.parentViewController = self.parentViewController
        dataSource.additionalTableViewDelegate = self
        return dataSource
        }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewLogic.delegate = self
        
        self.tableView.tableFooterView = self.footerView
        dataSource.configureTable(tableView)
        
        subscribeToNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.viewLogic.objects.isEmpty {
            self.viewLogic.fetch()
        }
        
        //UIKit bug?
        self.refreshControl?.removeFromSuperview()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("handleRefresh:"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.sendSubviewToBack(refreshControl)
        self.refreshControl = refreshControl
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.viewLogic.canFetch && !self.viewLogic.isFetching && indexPath.row == self.viewLogic.objects.count - 1 {
            self.viewLogic.fetch()
        }
    }
    
    func handleRefresh(refreshControl : UIRefreshControl) {
        self.viewLogic.refresh()
    }
    
    //MARK: Notifications
    
    private func subscribeToNotifications() {
        subscriptionUpdateObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfileViewController.SubscriptionDidChangeNotification,
            object: nil,
            queue: nil) { [weak self] (_: NSNotification!) -> Void in
                if let viewLoaded = self?.isViewLoaded() where viewLoaded == true {
                    self?.viewLogic.refresh()
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
            self.viewLogic.refresh()
        }
    }
    
    //MARK: FetchViewLogicDelegate
    
    func didUpdateObjects(objects : [UserInfo]) {
        if objects.count > 0 {
            self.dataSource.setUserList(objects)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func fetchStatusChanged(isFetching : Bool) {
        self.tableView.tableFooterView?.hidden = false
        if isFetching {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func noContentAvailable() {
        self.tableView.tableFooterView?.hidden = true;
    }
}

final class PeopleExploreDataSource: TableViewDataSource {
    private var items: [UserInfoTableViewCellModel] = []
    internal weak var additionalTableViewDelegate : UITableViewDelegate?
    
    func setUserList(users: [UserInfo]) {
        items = users.sort { ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == NSComparisonResult.OrderedAscending }.map{ UserInfoTableViewCellModel(userInfo: $0) }
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        self.additionalTableViewDelegate?.tableView!(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
}