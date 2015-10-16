//
//  UserProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol UserProfileActionConsumer: class {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction)
}

final class UserProfileViewController: BesideMenuViewController, BrowseActionProducer, UITextFieldDelegate, SearchViewControllerDelegate {
    
    weak var actionConsumer: BrowseActionConsumer?
    
    enum Sections: Int {
        case Info, Feed
    }
    
    enum ProfileAction: Int, Printable {
        case None
        case Call, Chat, Edit, Follow, UnFollow
        var description: String {
            switch self {
            case .None:
                return "Empty action"
            case .Call:
                return "Contact"
            case .Chat:
                return "SendMessage"
            case .Edit:
                return "Edit profile"
            case .Follow:
                return "Follow"
            case .UnFollow:
                return "Unfollow"
            }
        }
    }
    
    var objectId: CRUDObjectId = api().currentUserId() ?? CRUDObjectInvalidId
    
    var profile: UserProfile = UserProfile(objectId: CRUDObjectInvalidId) {
        didSet {
            if isViewLoaded() {
                didReceiveProfile(profile)
            }
        }
    }

    static let SubscriptionDidChangeNotification = "SubscriptionDidChangeNotification"
    
    //MARK: - Reload data -
    
    func reloadData() {
        api().getUserProfile(objectId).zip(api().getSubscriptionStateForUser(objectId)).onSuccess {
            [weak self] profile, state in
            self?.didReceiveProfile(profile, state: state)
        }
    }
    
    private func didReceiveProfile(profile: UserProfile, state: UserProfile.SubscriptionState = .SameUser) {
        let isCurrentUser = api().isCurrentUser(objectId)
        let isUserAuthorized: Bool = api().isUserAuthorized()
        let (leftAction, rightAction): (UserProfileViewController.ProfileAction, UserProfileViewController.ProfileAction) =
        (.None, .None)
        //TODO: should use info about current auth status
        if isUserAuthorized {
            setNavigationBarButtonItem(isCurrentUser)
        }
        
        var infoSection: [ProfileCellModel] = [
            ProfileInfoCellModel(name: profile.displayName, avatar: profile.avatar, background: profile.backgroundImage, leftAction: leftAction, rightAction: rightAction, actionDelegate: self),
            TableViewCellTextModel(title: profile.userDescription ?? ""),
            ProfileStatsCellModel(countPosts: profile.countPosts, countFollowers: profile.countFollowers, countFollowing: profile.countFollowing),
        ]
        switch state {
        case .SameUser:
            break
        default:
            infoSection.append(ProfileFollowCellModel(state: state, actionDelegate: self))
            break
        }
        dataSource.items[Sections.Info.rawValue] = infoSection
        
        var feedModel = BrowseListCellModel(objectId: profile.objectId, actionConsumer: self, browseMode: .New)
        feedModel.excludeCommunityItems = true
        dataSource.items[Sections.Feed.rawValue] = [ feedModel ]
        
        tableView.reloadData()
        actionConsumer?.browseControllerDidChangeContent(self)
    }
    
    func setNavigationBarButtonItem(isCurrentUser: Bool) {
        let navigationBarButtonActionSelector : Selector = "handleNavigationBarButtonItemTap:"
        let navigationBarButtonWidthSize : CGFloat = 40
        
        if (isCurrentUser) {
            let profileEditButton = UIButton()
            profileEditButton.tintColor = UIColor.whiteColor()
            profileEditButton.setImage(UIImage(named: "profileEdit")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
            profileEditButton.frame = CGRectMake(0, 0, navigationBarButtonWidthSize, navigationBarButtonWidthSize)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileEditButton)
            profileEditButton.tag = ProfileAction.Edit.rawValue
            profileEditButton.addTarget(self, action: navigationBarButtonActionSelector,
                forControlEvents: UIControlEvents.TouchUpInside)
        }
        else {
            let chatButton = UIButton()
            chatButton.tintColor = UIColor.whiteColor()
            chatButton.setImage(UIImage(named: "profileChat")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
            chatButton.frame = CGRectMake(0, 0, navigationBarButtonWidthSize, navigationBarButtonWidthSize)
            chatButton.tag = ProfileAction.Chat.rawValue
            chatButton.addTarget(self, action: navigationBarButtonActionSelector,
                forControlEvents: UIControlEvents.TouchUpInside)
            
            let callButton = UIButton()
            callButton.tintColor = UIColor.whiteColor()
            callButton.setImage(UIImage(named: "profileCall")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
            callButton.frame = CGRectMake(navigationBarButtonWidthSize, 0, navigationBarButtonWidthSize, navigationBarButtonWidthSize)
            callButton.tag = ProfileAction.Call.rawValue
            callButton.addTarget(self, action: navigationBarButtonActionSelector,
                forControlEvents: UIControlEvents.TouchUpInside)
            
            let containerView = UIView()
            containerView.frame = CGRectMake(0, 0, navigationBarButtonWidthSize * 2, navigationBarButtonWidthSize)
            containerView.addSubview(callButton)
            containerView.addSubview(chatButton)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containerView)
        }
    }
    
    @IBAction func handleNavigationBarButtonItemTap(sender: UIButton) {
        if let action = UserProfileViewController.ProfileAction(rawValue: sender.tag) where action != .None {
            self.shouldExecuteAction(action)
        }
    }
    
    //MARK: - Table -
    @IBOutlet private weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.titleView = searchbar
        dataSource.configureTable(tableView)
        didReceiveProfile(profile)
        reloadData()
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    lazy var dataSource: ProfileDataSource = { [unowned self] in
        let dataSource = ProfileDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    

    private func sendSubscriptionUpdateNotification(aUserInfo: [NSObject : AnyObject]? = nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            UserProfileViewController.SubscriptionDidChangeNotification,
            object: self,
            userInfo: nil
        )
    }
    
    //MARK: - Search -
    
    private lazy var searchbar: UITextField = { [unowned self] in
        let searchBar = UITextField(frame: CGRectMake(0, 0, UIScreen.mainScreen().applicationFrame.size.width * 0.7, 25))
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.borderStyle = UITextBorderStyle.RoundedRect
        let leftView = UIImageView(image: UIImage(named: "search_icon"))
        searchBar.leftView = leftView
        searchBar.leftViewMode = .Always
        searchBar.delegate = self
        return searchBar
        }()
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        SearchViewController.present(searchbar, presenter: self)
        return false
    }
    
    func searchViewControllerItemSelected(model: SearchItemCellModel?) {
        
    }
    
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?) {
        
    }
}

extension UserProfileViewController: UserProfileActionConsumer {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction) {
        switch action {
        case .Edit:
            let updateController = Storyboards.NewItems.instantiateEditProfileViewController()
            subscribeForContentUpdates(updateController)
            let navigationController = UINavigationController(rootViewController: updateController)
            presentViewController(navigationController, animated: true, completion: nil)
        case .Follow:
            api().followUser(objectId).onSuccess { [weak self] in
                self?.sendSubscriptionUpdateNotification(aUserInfo: nil)
                self?.reloadData()
            }
        case .UnFollow:
            api().unFollowUser(objectId).onSuccess { [weak self] in
                self?.sendSubscriptionUpdateNotification(aUserInfo: nil)
                self?.reloadData()
            }
        case .Chat:
            showChatViewController(objectId)
        case .Call:
            if let phone = profile.phone,
                let phoneNumberURL = NSURL(string: "tel://" + phone)
                where UIApplication.sharedApplication().canOpenURL(phoneNumberURL) == true {
                    UIApplication.sharedApplication().openURL(phoneNumberURL)
            }
        case .None:
            fallthrough
        default:
            Log.warning?.message("Unhandled action \(action)")
        }
    }
}

extension UserProfileViewController: BrowseActionConsumer {
    
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType, data: Any?) {
        switch itemType {
        case .Item:
            let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
            controller.objectId = objectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Event:
            let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .Promotion:
            let controller =  Storyboards.Main.instantiatePromotionDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .Post:
            let controller = Storyboards.Main.instantiatePostViewController()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        default:
            Log.debug?.message("Did select \(itemType)<\(objectId)>")
        }
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

extension UserProfileViewController {
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