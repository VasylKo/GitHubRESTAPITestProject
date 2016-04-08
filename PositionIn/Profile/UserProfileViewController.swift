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
    
    enum ProfileAction: Int, CustomStringConvertible {
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
    var childFilterUpdate: SearchFilterUpdate?
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
            
            //send event to analytic
            trackEventToAnalytics(AnalyticCategories.people, action: AnalyticActios.followingCount, value: NSNumber(integer: profile.countFollowing ?? 0))
            trackEventToAnalytics(AnalyticCategories.people, action: AnalyticActios.followersCount, value: NSNumber(integer: profile.countFollowers ?? 0))
        }.onComplete(callback: { [weak self] _ in
                self?.tableView.userInteractionEnabled = true
                })
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
        
        self.updateFeed()
    }
    
    private func updateFeed() {
        var feedModel = BrowseListCellModel(objectId: objectId, actionConsumer: self, browseMode: .New)
        feedModel.excludeCommunityItems = true
        feedModel.childFilterUpdate = self.childFilterUpdate
        
        //hide user feed
//        dataSource.items[Sections.Feed.rawValue] = [ feedModel ]
        
        tableView.reloadData()
//        actionConsumer?.browseControllerDidChangeContent(self)
    }
    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        super.contentDidChange(sender, info: info)
        if isViewLoaded() {
            reloadData()
        }
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
        } else {
            let chatButton = UIButton()
            chatButton.tintColor = UIColor.whiteColor()
            chatButton.setImage(UIImage(named: "profileChat")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
            chatButton.frame = CGRectMake(0, 0, navigationBarButtonWidthSize, navigationBarButtonWidthSize)
            chatButton.tag = ProfileAction.Chat.rawValue
            chatButton.addTarget(self, action: navigationBarButtonActionSelector,
                forControlEvents: UIControlEvents.TouchUpInside)
            
            let containerView = UIView()
            containerView.frame = CGRectMake(0, 0, navigationBarButtonWidthSize, navigationBarButtonWidthSize)
            containerView.addSubview(chatButton)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containerView)
        }
    }
    
    @IBAction func handleNavigationBarButtonItemTap(sender: UIButton) {
        if let action = UserProfileViewController.ProfileAction(rawValue: sender.tag) where action != .None {
            trackEventToAnalytics(AnalyticCategories.profile, action: AnalyticActios.edit)
            self.shouldExecuteAction(action)
        }
    }
    
    //MARK: - Table -
    @IBOutlet private weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationItem.titleView = searchbar
        dataSource.configureTable(tableView)
        didReceiveProfile(profile)
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if api().isCurrentUser(objectId) {
            trackScreenToAnalytics(AnalyticsLabels.profile)
        } else {
            trackScreenToAnalytics(AnalyticsLabels.peopleDetails)
        }
        
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        if segue == EditProfileViewController.Segue.Close {
            trackEventToAnalytics(AnalyticCategories.profile, action: AnalyticActios.editDone, label: NSLocalizedString("Cancel"))
        }
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
        let width = self.navigationController?.navigationBar.frame.size.width
        let searchBar = UITextField(frame: CGRectMake(0, 0, width! * 0.7, 32))
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIScheme.searchbarBgColor
        searchBar.borderStyle = UITextBorderStyle.RoundedRect
        searchBar.font = UIFont(name: "Helvetica", size: 16)
        searchBar.textColor = UIColor.whiteColor()
        let leftView: UIImageView = UIImageView(image: UIImage(named: "search_icon"))
        leftView.frame = CGRectMake(0.0, 0.0, leftView.frame.size.width + 5.0, leftView.frame.size.height);
        leftView.contentMode = .Center
        searchBar.leftView = leftView
        searchBar.leftViewMode = .Always
        searchBar.delegate = self
        let str = NSAttributedString(string: "Search...", attributes: [NSForegroundColorAttributeName:UIColor(white: 255, alpha: 0.5),
            NSFontAttributeName: UIFont(name: "Helvetica", size: 16)!])
        searchBar.attributedPlaceholder =  str
        return searchBar
        }()
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        var searchFilter: SearchFilter = SearchFilter.currentFilter
        searchFilter.users = [objectId]
        SearchViewController.present(searchbar, presenter: self, filter: searchFilter)
        self.searchbar.text = nil
        self.searchbar.attributedText = nil
        return false
    }
    
    func searchViewControllerSearchStringSelected(searchString: String?, locationString: String?) {
        self.searchbar.attributedText = self.searchBarAttributedText(nil,
            searchString: searchString,
            locationString: locationString)
        childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
            var f = filter
            f.name = searchString
            return f
        }
        self.updateFeed()
    }
    
    func searchViewControllerItemSelected(model: SearchItemCellModel?, searchString: String?, locationString: String?) {
        if let model = model {
            
            switch model.itemType {
            case .Unknown:
                break
            case .Category:
                break
            case .Product:
                let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Event:
                let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
                controller.objectId = model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Promotion:
                let controller =  Storyboards.Main.instantiatePromotionDetailsViewControllerId()
                controller.objectId =  model.objectID
                navigationController?.pushViewController(controller, animated: true)
            case .Community:
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.communities = [model.objectID]
                    return f
                }
                self.updateFeed()
            case .People:
                childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                    var f = filter
                    f.users = [model.objectID]
                    return f
                }
                self.updateFeed()
            }
            self.searchbar.text = nil
            self.searchbar.attributedText = self.searchBarAttributedText(model.title, searchString: searchString, locationString: locationString)
        }
    }
    
    func searchViewControllerLocationSelected(locationString: String?) {
        if let locationString = locationString {
            self.searchbar.attributedText = NSMutableAttributedString(string: locationString,
                attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        }
    }
    
    func searchViewControllerSectionSelected(model: SearchSectionCellModel?, searchString: String?, locationString: String?) {
        if let model = model {
            let itemType = model.itemType
            childFilterUpdate = { (filter: SearchFilter) -> SearchFilter in
                var f = filter
                f.itemTypes = [ itemType ]
                return f
            }
            self.searchbar.text = itemType.description
            self.updateFeed()
            self.searchbar.attributedText = self.searchBarAttributedText(model.title, searchString: searchString, locationString: locationString)
        }
    }
    
    func searchBarAttributedText(modelTitle: String?, searchString: String?, locationString: String?) -> NSAttributedString {
        
        var str: NSMutableAttributedString = NSMutableAttributedString()
        var searchBarString: String = ""
        
        if let modelTitle = modelTitle {
            searchBarString = modelTitle
        }
        
        if let searchString = searchString {
            searchBarString = searchBarString + " " + searchString
        }
        
        if let locationString = locationString {
            searchBarString = searchBarString + " " + locationString
        }
        
        str = NSMutableAttributedString(string: searchBarString,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        return str
    }
    
    func searchViewControllerCancelSearch() {
        childFilterUpdate = nil
        self.updateFeed()
        
        if let locationString = SearchFilter.currentFilter.locationName {
            self.searchbar.attributedText = NSMutableAttributedString(string: locationString,
                attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        }
    }
}

//MARK: - Actions -

extension UserProfileViewController: UserProfileActionConsumer {
    func shouldExecuteAction(action: UserProfileViewController.ProfileAction) {
        switch action {
        case .Edit:
            let updateController = Storyboards.NewItems.instantiateEditProfileViewController()
            subscribeForContentUpdates(updateController)
            let navigationController = UINavigationController(rootViewController: updateController)
            navigationController.navigationBar.barTintColor = UIScheme.mainThemeColor
            navigationController.navigationBar.translucent = false
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            presentViewController(navigationController, animated: true, completion: nil)
        case .Follow:
            if api().isUserAuthorized() {
                self.tableView.userInteractionEnabled = false
                api().followUser(objectId).onSuccess { [weak self] in
                    self?.sendSubscriptionUpdateNotification(nil)
                    self?.reloadData()
                    
                    //Sent event to analytics
                    let personID = self?.objectId ?? NSLocalizedString("Unknown ID")
                    trackEventToAnalytics(AnalyticCategories.people, action: AnalyticActios.follow, label: NSLocalizedString("Person + ") + personID)
                }
                
            }
        case .UnFollow:
            self.tableView.userInteractionEnabled = false
            api().unFollowUser(objectId).onSuccess { [weak self] in
                self?.sendSubscriptionUpdateNotification(nil)
                self?.reloadData()
                
                //Sent event to analytics
                let personID = self?.objectId ?? NSLocalizedString("Unknown ID")
                trackEventToAnalytics(AnalyticCategories.people, action: AnalyticActios.unfollow, label: NSLocalizedString("Person + ") + personID)
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
    
    func browseController(controller: BrowseActionProducer, didSelectItem object: Any, type itemType: FeedItem.ItemType, data: Any?) {
        switch itemType {
            
        case .Project:
            let controller =  Storyboards.Main.instantiateProductDetailsViewControllerId()
            controller.objectId = objectId
            controller.author = data as? ObjectInfo
            navigationController?.pushViewController(controller, animated: true)
        case .Emergency:
            let controller =  Storyboards.Main.instantiateEventDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .Training:
            let controller =  Storyboards.Main.instantiateTrainingDetailsViewControllerId()
            controller.objectId = objectId
            navigationController?.pushViewController(controller, animated: true)
        case .GiveBlood:
            fallthrough
        case .News:
            fallthrough
        case .Event:
            fallthrough
        case .Market:
            fallthrough
        case .BomaHotels:
            fallthrough
        case .Volunteer:
            fallthrough
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

//MARK: - Table -

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
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            let model = self.tableView(tableView, modelForIndexPath: indexPath)
            switch model {
            case  _ as ProfileInfoCellModel:
                return ProfileInfoCell.reuseId()
            case  _ as ProfileStatsCellModel:
                return ProfileStatsCell.reuseId()
            case _ as BrowseListCellModel:
                return BrowseListTableViewCell.reuseId()
            case _ as TableViewCellTextModel:
                return DescriptionTableViewCell.reuseId()
            case _ as ProfileFollowCellModel:
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
                where model.title.characters.count == 0 {
                    return 0.0
            }
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}