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


protocol PeopleActionConsumer {
    func showProfileScreen(userId: CRUDObjectId)
}


final class PeopleViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        browseMode = .Following
        subscribeToNotifications()
        //Remove following section for not registred users
        if !api().isUserAuthorized() {
            browseMode = .Explore
            self.browseModeSegmentedControl.removeSegmentAtIndex(0, animated: false)
        }
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
            let mySubscriptionsRequest = api().getMySubscriptions()
            if firstFollowingRequestToken.isInvalid {
                peopleRequest = mySubscriptionsRequest
            } else {
                // On first load switch to explore if not following any user
                firstFollowingRequestToken.invalidate()
                peopleRequest = mySubscriptionsRequest.flatMap { response -> Future<CollectionResponse<UserInfo>,NSError> in
                    if let userList = response.items  where userList.count == 0 {
                        return Future.failed(NSError())
                    } else {
                        return Future.succeeded(response)
                    }
                }.andThen { [weak self] result in
                    switch result {
                    case .Failure(_):
                        self?.browseMode = .Explore
                    default:
                        break
                    }
                }
            }
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
        super.contentDidChange(sender, info: info)
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
    private let firstFollowingRequestToken = InvalidationToken()

    private lazy var dataSource: PeopleListDataSource = { [unowned self] in
        let dataSource = PeopleListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}

extension PeopleViewController: PeopleActionConsumer {
    func showProfileScreen(userId: CRUDObjectId) {
        let profileController = Storyboards.Main.instantiateUserProfileViewController()
        profileController.objectId = userId
        navigationController?.pushViewController(profileController, animated: true)
    }
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
        
        if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? UserInfoTableViewCellModel,
           let parentViewController = parentViewController as? PeopleActionConsumer {
            parentViewController.showProfileScreen(model.userInfo.objectId)
        }
    }

}
