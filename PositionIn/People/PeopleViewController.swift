//
//  PeopleViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 08/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger


final class PeopleViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        browseMode = .Following
        subscribeToNotifications()
    }
    
    var browseMode: BrowseMode = .Following {
        didSet {
            browseModeSegmentedControl.selectedSegmentIndex = browseMode.rawValue
            reloadData()
        }
    }
    
    enum BrowseMode: Int {
        case Following
        case Explore
    }
    
    func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let peopleRequest: Future<CollectionResponse<UserInfo>,NSError>
        switch browseMode {
        case .Following:
            peopleRequest = api().getMySubscriptions()
        case .Explore:
            peopleRequest = api().getUsers(APIService.Page())
        }
        peopleRequest.onSuccess(token: dataRequestToken) { [weak self] response in
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
        NSNotificationCenter.defaultCenter().removeObserver(subscriptionUpdateObserver)

    }
    
    private var subscriptionUpdateObserver: NSObjectProtocol!
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        if isViewLoaded() {
            reloadData()
        }
    }

    @IBAction func browseModeSegmentChanged(sender: UISegmentedControl) {
        if let mode = BrowseMode(rawValue: sender.selectedSegmentIndex) {
            browseMode = mode
        }
    }
    
    @IBOutlet private weak var browseModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var tableView: TableView!
    
    private var dataRequestToken = InvalidationToken()

    private lazy var dataSource: PeopleListDataSource = {
        let dataSource = PeopleListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}

final class PeopleListDataSource: TableViewDataSource {
    private var items: [UserInfoTableViewCellModel] = []

    
    func setUserList(users: [UserInfo]) {
        items = users.map { UserInfoTableViewCellModel(userInfo: $0) }
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
        //TODO: move logic to the controller
        
        if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? UserInfoTableViewCellModel,
           let parentViewController = parentViewController{
            let profileController = Storyboards.Main.instantiateUserProfileViewController()
            profileController.objectId = model.userInfo.objectId
            parentViewController.navigationController?.pushViewController(profileController, animated: true)
        }
    }

}
