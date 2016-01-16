
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
        switch (objectId, author) {
        case (.Some(let objectId), .Some(let author) ):
            api().getUserProfile(author.objectId).flatMap { (profile: UserProfile) -> Future<Community, NSError> in
                return api().getVolunteer(objectId)
                }.onSuccess {[weak self] volunteer in
                    self?.didReceiveDetails(volunteer)
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
        
        let image = UIImage(named: "hardware_img_default")
        
        productImageView.setImageFromURL(volunteer.avatar, placeholder: image)
        if let coordinates = volunteer.location?.coordinates {
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
            }
        }
    }
    
    enum ControllerType : Int {
        case Unknown, Community, Volunteer
    }
    
    var type : ControllerType = .Unknown
    var joinAction : Bool = true
    
    var objectId: CRUDObjectId?
    var author: ObjectInfo?
    
    private var volunteer: Community?
    private var locationRequestToken = InvalidationToken()
    
    private lazy var dataSource: VolunteerDetailsDataSource = { [unowned self] in
        let dataSource = VolunteerDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[VolunteerActionItem]] {
        let firstSection = [
            VolunteerActionItem(title: NSLocalizedString("Send Message", comment: "Volunteer"), image: "productSendMessage", action: .SendMessage),
            VolunteerActionItem(title: NSLocalizedString("Organizer Profile", comment: "Volunteer"), image: "productSellerProfile", action: .SellerProfile),
            VolunteerActionItem(title: NSLocalizedString("More Information", comment: "Volunteer"), image: "productTerms&Info", action: .ProductInventory)]
        
        if (self.joinAction != true) {
            //public or joined case
            return [firstSection]
        } else {
            var joinActionItem : VolunteerActionItem
            switch self.type {
            case .Volunteer:
                joinActionItem = VolunteerActionItem(title: NSLocalizedString("Volunteer", comment: "Volunteer"), image: "home_volunteer",action: .Join)
            case .Community:
                joinActionItem = VolunteerActionItem(title: NSLocalizedString("Join", comment: "Community"), image: "home_volunteer",action: .Join)
            case .Unknown:
                //TODO:change .Buy
                joinActionItem = VolunteerActionItem(title: "", image: "", action: .Join)
            }
            return [[joinActionItem], firstSection]
        }
    }
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension VolunteerDetailsViewController {
    enum VolunteerDetailsAction: CustomStringConvertible {
        case Join, ProductInventory, SellerProfile, SendMessage
        
        var description: String {
            switch self {
            case .Join:
                return "Join"
            case .ProductInventory:
                return "Product Inventory"
            case .SellerProfile:
                return "Seller profile"
            case .SendMessage:
                return "Send message"
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
        case .SellerProfile:
            segue = .ShowOrganizerProfile
        case .SendMessage:
            if let userId = author?.objectId {
                showChatViewController(userId)
            }
            return
        case .Join:
            if api().isUserAuthorized() && self.objectId != nil {
                switch self.type {
                case .Volunteer:
                    if self.objectId != nil {
                        api().joinVolunteer(self.objectId!).onSuccess { [weak self] _ in
                            //on success
                        }
                    } else {
                        Log.error?.message("objectId is nil")
                    }
                    return
                case .Community:
                    if self.objectId != nil {
                        api().joinCommunity(self.objectId!).onSuccess { [weak self] _ in
                            //on success
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
        case .ProductInventory:
            return
        }
        performSegue(segue)
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
