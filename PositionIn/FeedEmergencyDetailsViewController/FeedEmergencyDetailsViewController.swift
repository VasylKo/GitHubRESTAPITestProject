//
//  FeedEmergencyDetailsViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 16/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//
import PosInCore

class FeedEmergencyDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        tableView.separatorStyle = .None
        self.reloadEmergency()
        
        tableView.separatorStyle = .SingleLine
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero;

        
        self.title = NSLocalizedString("Emergency")
        self.tableView.backgroundColor = UIColor.bt_colorWithBytesR(238, g: 238, b: 238)
    }
    
    private func reloadEmergency() {
        if let objectId = objectId {
            api().getEmergencyDetails(objectId).onSuccess { [weak self] emergency in
                if let coordinates = emergency.location?.coordinates {
                    var emergency = emergency
                    locationController().distanceFromCoordinate(coordinates).onSuccess() {
                        [weak self] distance in
                        let formatter = NSLengthFormatter()
                        emergency.distanceString = formatter.stringFromMeters(distance)
                        
                        self?.emergency = emergency
                        self?.dataSource.setEmergency(emergency)
                        self?.tableView.reloadData()
                        self?.tableView.layoutIfNeeded();
                    }
                }
                else {
                    self?.emergency = emergency
                    self?.dataSource.setEmergency(emergency)
                    self?.tableView.reloadData()
                    self?.tableView.layoutIfNeeded();
                }
            }
        }
    }
    
    private lazy var dataSource: FeedEmergencyDataSource = { [unowned self] in
        let dataSource = FeedEmergencyDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    @IBOutlet weak var tableView: TableView!
    var objectId: CRUDObjectId?
    private var emergency: Product?
}

extension FeedEmergencyDetailsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension FeedEmergencyDetailsViewController {
    internal class FeedEmergencyDataSource: TableViewDataSource {
        
        var actionConsumer: NewsActionConsumer? {
            return parentViewController as? NewsActionConsumer
        }
        
        private let cellFactory = FeedEmergencyCellModel()
        private var items: [[TableViewCellModel]] =  [[],[]]
        
        func setEmergency(emergency: Product) {
            items = cellFactory.modelsForEmergency(emergency, actionConsumer: self.actionConsumer)
        }
        
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
            return cellFactory.cellReuseIdForModel(self.tableView(tableView, modelForIndexPath: indexPath))
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return cellFactory.emergencyCellsReuseId()
        }
        
        @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 1 {
                return 25
            }
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        @objc override func tableView(tableView: UITableView,
            willDisplayCell cell: UITableViewCell,
            forRowAtIndexPath indexPath: NSIndexPath) {
                cell.layoutMargins = UIEdgeInsetsZero
                cell.preservesSuperviewLayoutMargins = false
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let _ = tableView.cellForRowAtIndexPath(indexPath) as? ActionCell {
                //TODO: need check not by title
                if let model = items[indexPath.section][indexPath.row] as? TableViewCellImageTextModel {
                    switch model.title {
                    case "Donate":
                        let donateController = Storyboards.Onboarding.instantiateDonateViewController()
                        let controller = self.parentViewController as! FeedEmergencyDetailsViewController
                        donateController.product = controller.emergency
                        controller.navigationController?.pushViewController(donateController, animated: true)
                        break
                    case "Send Message":
                        let controller = self.parentViewController as! FeedEmergencyDetailsViewController
                        if let userId = controller.emergency?.author?.objectId {
                            controller.showChatViewController(userId)
                        }
                        break
                    case "Member Profile":
                        let controller = self.parentViewController as! FeedEmergencyDetailsViewController
                        
                        if let userId = controller.emergency?.author?.objectId {
                            let profileController = Storyboards.Main.instantiateUserProfileViewController()
                            profileController.objectId = userId
                            controller.navigationController?.pushViewController(profileController, animated: true)
                        }
                        
                        break
                    case "More Information":
                        let controller = self.parentViewController as! FeedEmergencyDetailsViewController
                        if controller.emergency?.links?.isEmpty == false || controller.emergency?.attachments?.isEmpty == false {
                            let moreInformationViewController = MoreInformationViewController(links: controller.emergency?.links,
                                attachments: controller.emergency?.attachments)
                            controller.navigationController?.pushViewController(moreInformationViewController, animated: true)
                        }
                        break
                    default: break
                    }
                }
            }
        }
    }
}