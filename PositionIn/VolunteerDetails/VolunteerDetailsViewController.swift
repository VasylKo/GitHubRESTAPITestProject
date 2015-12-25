
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
        title = NSLocalizedString("Volunteer", comment: "Volunteer")
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
            api().getUserProfile(author.objectId).flatMap { (profile: UserProfile) -> Future<Event, NSError> in
                return api().getVolunteerDetails(objectId)
                }.onSuccess { [weak self] volunteer in
                    self?.didReceiveDetails(volunteer)
            }
        default:
            Log.error?.message("Not enough data to load product")
        }
    }
    
    private func didReceiveDetails(product: Event) {
        self.product = product
        headerLabel.text = product.name
        detailsLabel.text = product.text?.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        if let participants = product.participants {
            priceLabel.text = "\(Int(participants)) beneficiaries"
        }
        
        let imageURL: NSURL?
        if let urlString = product.imageURLString {
            imageURL = NSURL(string:urlString)
        } else {
            imageURL = nil
        }
        
        let image = UIImage(named: "hardware_img_default")
        
        productImageView.setImageFromURL(imageURL, placeholder: image)
        if let coordinates = product.location?.coordinates {
            locationRequestToken.invalidate()
            locationRequestToken = InvalidationToken()
            locationController().distanceFromCoordinate(coordinates).onSuccess(locationRequestToken.validContext) {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
            }
        }
    }
    
    var objectId: CRUDObjectId?
    var author: ObjectInfo?
    
    private var product: Event?
    private var locationRequestToken = InvalidationToken()
    
    private lazy var dataSource: VolunteerDetailsDataSource = { [unowned self] in
        let dataSource = VolunteerDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func productAcionItems() -> [[VolunteerActionItem]] {
        return [
            [ // 0 section
                VolunteerActionItem(title: NSLocalizedString("Volunteer", comment: "Volunteer"),
                    image: "home_volunteer",
                    action: .Buy),
            ],
            [ // 1 section
                VolunteerActionItem(title: NSLocalizedString("Send Message", comment: "Volunteer"), image: "productSendMessage", action: .SendMessage),
                VolunteerActionItem(title: NSLocalizedString("Organizer Profile", comment: "Volunteer"), image: "productSellerProfile", action: .SellerProfile),
                VolunteerActionItem(title: NSLocalizedString("Navigate", comment: "Volunteer"), image: "productNavigate", action: .ProductInventory),
                VolunteerActionItem(title: NSLocalizedString("More Information", comment: "Volunteer"), image: "productTerms&Info", action: .ProductInventory),
            ],
        ]
        
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
        case Buy, ProductInventory, SellerProfile, SendMessage
        
        var description: String {
            switch self {
            case .Buy:
                return "Buy"
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
        case .Buy:
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
