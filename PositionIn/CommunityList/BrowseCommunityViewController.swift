//
//  CommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger

protocol BrowseCommunityActionConsumer: class {
    func executeAction(action: BrowseCommunityViewController.Action, community: Community)
}

protocol BrowseCommunityActionProvider {
    var actionConsumer: BrowseCommunityActionConsumer? { get set }
}


class BrowseCommunityViewController: BesideMenuViewController, BrowseCommunityActionConsumer {
    
    enum Action: Int, CustomStringConvertible {
        case None
        case Browse
        case Join
        case Post
        case Invite
        case Edit
        case Leave
        
        func displayText() -> String {
            switch self {
            case .None, .Browse:
                return NSLocalizedString("VIEW", comment: "Community action: view")
            case .Join:
                return NSLocalizedString("JOIN", comment: "Community action: Join")
            case .Post:
                return NSLocalizedString("POST", comment: "Community action: Post")
            case .Invite:
                return NSLocalizedString("INVITE", comment: "Community action: Invite")
            case .Edit:
                return NSLocalizedString("EDIT", comment: "Community action: Edit")
            case .Leave:
                return NSLocalizedString("LEAVE", comment: "Community action: Leave")
            }
        }
        
        var description: String {
            return "<Community Action:\(displayText())>"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Communities"
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        dataSource.configureTable(tableView)
        browseMode = .MyGroups
        self.browseModeSegmentedControl.tintColor = UIScheme.mainThemeColor
        //Remove following section for not registred users
        if !api().isUserAuthorized() {
            browseMode = .Explore
            self.browseModeSegmentedControl.removeSegmentAtIndex(0, animated: false)
        }
    }
    
    private var firstLoad: Bool = true
    
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
            let mySubscriptionsRequest = api().currentUserId().flatMap { userId in
                return api().getUserCommunities(userId)
            }
            if firstMyCommunityRequestToken.isInvalid {
                communitiesRequest = mySubscriptionsRequest
            } else {
                // On first load switch to explore if not join any community
                firstMyCommunityRequestToken.invalidate()
                communitiesRequest = mySubscriptionsRequest.flatMap {  response -> Future<CollectionResponse<Community>,NSError> in
                    if let communitiesList = response.items  where communitiesList.count == 0 {
                        return Future(error: NetworkDataProvider.ErrorCodes.InvalidRequestError.error())
                    } else {
                        return Future(value: response)
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
            communitiesRequest = api().getCommunities(APIService.Page())
        }
        communitiesRequest.onSuccess(dataRequestToken.validContext) { [weak self] response in
            if let communities = response.items {
                Log.debug?.value(communities)
                self?.dataSource.setCommunities(communities, mode: browseMode)
                self?.tableView.reloadData()
            }
        }
    }
    
    lazy var dataSource: BrowseCommunityDataSource = { [unowned self] in
        let dataSource = BrowseCommunityDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        super.contentDidChange(sender, info: info)
        ConversationManager.sharedInstance().refresh()
        if isViewLoaded() {
            reloadData()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let volunteerDetailsViewController = segue.destinationViewController  as? VolunteerDetailsViewController {
            volunteerDetailsViewController.volunteer = self.selectedObject
            volunteerDetailsViewController.joinAction = (self.browseModeSegmentedControl.selectedSegmentIndex == 1) 
            volunteerDetailsViewController.type = VolunteerDetailsViewController.ControllerType.Community
            volunteerDetailsViewController.author = self.selectedObject?.owner
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func browseModeSegmentChanged(sender: UISegmentedControl) {
        if let mode = BrowseMode(rawValue: sender.selectedSegmentIndex) {
            browseMode = mode
        }
    }
    
    /* access control: protected variables (only for inheritance usage) */
    @IBOutlet weak var browseModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: TableView!
    
    let firstMyCommunityRequestToken = InvalidationToken()
    var dataRequestToken = InvalidationToken()
    
    
    /* BrowseCommunityActionConsumer */
    
    var selectedObject : Community?
    
    func executeAction(action: BrowseCommunityViewController.Action, community: Community) {
        let communityId = community.objectId
        switch action {
        case .Join:
            if api().isUserAuthorized() {
                api().joinCommunity(communityId).onSuccess { [weak self] _ in
                    self?.reloadData()
                    ConversationManager.sharedInstance().refresh()
                }
            }
            else {
                api().logout().onComplete {[weak self] _ in
                    self?.sideBarController?.executeAction(.Login)
                }
            }
            break
        case .Browse, .None:
            switch self.browseModeSegmentedControl.selectedSegmentIndex {
            case 0:
                let controller = Storyboards.Main.instantiateCommunityViewController()
                controller.objectId = communityId
                controller.controllerType = .Community
                navigationController?.pushViewController(controller, animated: true)
            case 1:
                self.selectedObject = community
                self.performSegue(BrowseCommunityViewController.Segue.showVolunteerDetailsViewController)
            default:
                break
            }
        case .Post:
            let controller = Storyboards.NewItems.instantiateAddPostViewController()
            controller.communityId = communityId
            navigationController?.pushViewController(controller, animated: true)
        case .Invite:
            break
        case .Edit:
            let controller = Storyboards.NewItems.instantiateEditCommunityViewController()
            controller.existingCommunityId = communityId
            navigationController?.pushViewController(controller, animated: true)
            self.subscribeForContentUpdates(controller)
        case .Leave:
            api().leaveCommunity(communityId).onSuccess(callback: { (Void) -> Void in
                self.reloadData()
            })
        }
    }
}

extension BrowseCommunityViewController {
    internal class BrowseCommunityDataSource: TableViewDataSource {
        
        var actionConsumer: BrowseCommunityActionConsumer? {
            return parentViewController as? BrowseCommunityActionConsumer
        }
        
        private var items: [[TableViewCellModel]] = []
        private let cellFactory = BrowseCommunityCellFactory()
        
        func setCommunities(communities: [Community], mode: BrowseCommunityViewController.BrowseMode) {
            items = communities.map { self.cellFactory.modelsForCommunity($0, mode: mode, actionConsumer: self.actionConsumer) }
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
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
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? BrowseCommunityTableViewCellModel {
                actionConsumer?.executeAction(model.tapAction, community: model.community)
            }
        }
    }
}
