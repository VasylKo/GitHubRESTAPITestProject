
import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol VolunteerDetailsActionConsumer {
    func executeAction(action: VolunteerDetailsViewController.VolunteerDetailsAction)
}

class VolunteerDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.type {
        case .Volunteer:
            self.title = NSLocalizedString("Volunteer", comment:"")
        case .Community:
            self.title = NSLocalizedString("Community", comment: "")
        default:
            break
        }
        dataSource.items = productAcionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileController = segue.destinationViewController  as? UserProfileViewController,
            let userId = author?.objectId {
                profileController.objectId = userId
        }
    }
    
    private func reloadData() {
        self.infoLabel.text = NSLocalizedString("Calculating...", comment: "Distance calculation process")
        switch self.volunteer {
        case .Some(let volunteer):
            switch self.type {
            case .Volunteer:
                api().getVolunteer(volunteer.objectId).onSuccess {[weak self] volunteer in
                    var volunteerVar = volunteer
                    volunteerVar.closed = nil
                    self?.didReceiveDetails(volunteerVar)
                    self?.dataSource.items = (self?.productAcionItems())!
                    self?.dataSource.configureTable((self?.actionTableView)!)
                }
            case .Community:
                api().getCommunity(volunteer.objectId).onSuccess {[weak self] volunteer in
                    self?.didReceiveDetails(volunteer)
                    self?.dataSource.items = (self?.productAcionItems())!
                    self?.dataSource.configureTable((self?.actionTableView)!)
                }
            default:
                break
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveDetails(volunteer: Community) {
        self.volunteer = volunteer
        headerLabel.text = volunteer.name
        detailsLabel.text = volunteer.communityDescription?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        priceLabel.text = "\(Int(volunteer.membersCount)) beneficiaries"
        
        var image: UIImage?
        
        switch self.type {
        case .Volunteer:
            image = UIImage(named: "volunteer_placeholder")
        case .Community:
            image = UIImage(named: "communityPlaceholder")
        default:
            break
        }
        
        productImageView.setImageFromURL(volunteer.avatar, placeholder: image)
        if let coordinates = volunteer.location?.coordinates {
            self.pinDistanceImageView.hidden = false
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
                }.onFailure(callback: { (error:NSError) -> Void in
                    self.pinDistanceImageView.hidden = true
                    self.infoLabel.text = "" })
            self.dataSource.items = self.productAcionItems()
            self.dataSource.configureTable(self.actionTableView)
        } else {
            self.pinDistanceImageView.hidden = true
            self.infoLabel.text = ""
        }
    }
    
    enum ControllerType : Int {
        case Unknown, Community, Volunteer
    }
    
    var type : ControllerType = .Unknown
    var joinAction : Bool = true
    
    var volunteer: Community?
    var author: ObjectInfo?
    
    private var locationRequestToken = InvalidationToken()
    
    private lazy var dataSource: VolunteerDetailsDataSource = { [unowned self] in
        let dataSource = VolunteerDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[VolunteerActionItem]] {
        var firstSection = [
            VolunteerActionItem(title: NSLocalizedString("Send Message", comment: "Volunteer"), image: "productSendMessage", action: .SendMessage),
            VolunteerActionItem(title: NSLocalizedString("Organizer Profile", comment: "Volunteer"), image: "productSellerProfile", action: .SellerProfile),
            /*VolunteerActionItem(title: NSLocalizedString("More Information", comment: "Volunteer"), image: "productTerms&Info", action: .ProductInventory)*/]
        if self.volunteer?.location != nil {
            firstSection.append(VolunteerActionItem(title: NSLocalizedString("Navigate", comment: "BomaHotels"), image: "productNavigate", action: .Navigate))
        }
        
        if (self.joinAction != true) {
            //public or joined case
            return [firstSection]
        } else {
            var actionItem : VolunteerActionItem
            let userId : CRUDObjectId = api().currentUserId() ?? CRUDObjectInvalidId
            let userRole : UserInfo.Role = self.volunteer?.members?.items.filter() {$0.objectId == userId}.first?.role ?? .Unknown
            switch userRole {
            case .Applicant:
                switch self.type {
                case .Volunteer:
                     actionItem = VolunteerActionItem(title: "Pending", image: "home_volunteer", action: .Pending)
                case .Community:
                     actionItem = VolunteerActionItem(title: "Pending", image: "MainMenuCommunity", action: .Pending)
                case .Unknown:
                     actionItem = VolunteerActionItem(title: "Pending", image: "", action: .Pending)
                }
            default:
                switch self.type {
                case .Volunteer:
                    actionItem = VolunteerActionItem(title: NSLocalizedString("Volunteer", comment: "Volunteer"), image: "home_volunteer",action: .Join)
                case .Community:
                    actionItem = VolunteerActionItem(title: NSLocalizedString("Join", comment: "Community"), image: "MainMenuCommunity",action: .Join)
                case .Unknown:
                    //TODO:change .Buy
                    actionItem = VolunteerActionItem(title: "", image: "", action: .Join)
                }
            }
            
            return [[actionItem], firstSection]
        }
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak var joinPublicCommunityActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pinDistanceImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension VolunteerDetailsViewController {
    enum VolunteerDetailsAction: CustomStringConvertible {
        case Join, Navigate, ProductInventory, SellerProfile, SendMessage, Pending
        
        var description: String {
            switch self {
            case .Join:
                return "Join"
            case .Navigate:
                return "Navigate"
            case .ProductInventory:
                return "Product Inventory"
            case .SellerProfile:
                return "Seller profile"
            case .SendMessage:
                return "Send message"
            case .Pending:
                return "Pending"
            }
        }
    }
    
    
    struct VolunteerActionItem {
        let title: String
        let image: String
        let action: VolunteerDetailsAction
    }
}

extension VolunteerDetailsViewController: VolunteerDetailsActionConsumer {
    func executeAction(action: VolunteerDetailsAction) {
        let segue: VolunteerDetailsViewController.Segue
        switch action {
        case .Pending:
            var title : String
            switch self.type {
            case .Volunteer:
                title = "Kenya Red Cross will review your volunteering request and respond within a few days"
            case .Community, .Unknown:
                title = "Kenya Red Cross will review your request and respond within a few days"
            }
            
            let alertController = UIAlertController(title: nil, message:
                title, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated:true, completion: nil)
            return
        case .SellerProfile:
            segue = .ShowOrganizerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Join:
            if api().isUserAuthorized() && self.volunteer?.objectId != nil {
                switch self.type {
                case .Volunteer:
                    let alertController = UIAlertController(title: nil, message:
                        "Kenya Red Cross will review your volunteering request and respond within a few days", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Volunteer", style: .Default, handler: { action in
                        switch action.style{
                        case .Default:
                            if let objId = self.volunteer?.objectId {
                                api().joinVolunteer(objId).onSuccess { [weak self] _ in
                                    self?.reloadData()
                                }
                            } else {
                                Log.error?.message("objectId is nil")
                            }
                        case .Cancel:
                            print("cancel")
                            
                        case .Destructive:
                            print("destructive")
                        }
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                case .Community:
                    if let objId = self.volunteer?.objectId {
                        if let community = self.volunteer {
                            
                            if let closed = community.closed {
                                if closed {
                                    self.joinClosedCommunity(community)
                                }
                                else {
                                    self.joinPublicCommunityActivityIndicator.startAnimating()
                                    api().joinCommunity(objId).onSuccess() { [weak self] _ in
                                        //navigate
                                        self?.joinPublicCommunityActivityIndicator.stopAnimating()
                                        let controller = Storyboards.Main.instantiateCommunityViewController()
                                        controller.objectId = objId
                                        controller.controllerType = .Community
                                        self?.navigationController?.showViewController(controller, sender: nil)
                                        //remove join action button
                                        self?.joinAction = false
                                        self?.dataSource.items = (self?.productAcionItems())!
                                        self?.dataSource.configureTable((self?.actionTableView)!)
                                        }.onFailure { [weak self] result in
                                            self?.joinPublicCommunityActivityIndicator.stopAnimating()
                                    }
                                }
                            }
                            else {
                                self.joinClosedCommunity(community)
                            }
                        }
                    } else {
                        Log.error?.message("objectId is nil")
                    }
                case .Unknown:
                    break
                }
            }
            else {
                api().logout().onComplete {[weak self] _ in
                    self?.sideBarController?.executeAction(.Login)
                }
            }
            return
        case .Navigate:
            if let coordinates = self.volunteer?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
            return
        case .ProductInventory:
            return
        }
        performSegue(segue)
    }
    
    private func joinClosedCommunity(community: Community) {
        let alertController = UIAlertController(title: nil, message:
            "Kenya Red Cross will review your community request and respond within a few days", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            switch action.style {
            case .Default:
                if let objectId = self.volunteer?.objectId {
                    api().joinCommunity(objectId).onSuccess { [weak self] _ in
                        self?.reloadData()
                    }
                } else {
                    Log.error?.message("objectId is nil")
                }
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        return
    }
}

extension VolunteerDetailsViewController {
    internal class VolunteerDetailsDataSource: TableViewDataSource {
        
        var items: [[VolunteerActionItem]] = []
        
        override func configureTable(tableView: UITableView) {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ActionCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = items[indexPath.section][indexPath.row]
            let model = TableViewCellImageTextModel(title: item.title, imageName: item.image)
            return model
        }
        
        @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 1 {
                return 50
            }
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        override func nibCellsId() -> [String] {
            return [ActionCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = items[indexPath.section][indexPath.row]
            if let actionConsumer = parentViewController as? VolunteerDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
    }
}
