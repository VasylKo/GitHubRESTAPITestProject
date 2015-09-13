//
//  EventDetailsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

protocol EventDetailsActionConsumer {
    func executeAction(action: EventDetailsViewController.EventDetailsAction)
}

final class EventDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Event", comment: "Event details: title")
        dataSource.items = eventActionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    
    private func reloadData() {
        if let objectId = objectId {
            api().getEvent(objectId).onSuccess { [weak self] event in
                self?.didReceiveEventDetails(event)
            }
        }
    }
    
    private func didReceiveEventDetails(event: Event) {
        self.event = event
        headerLabel.text = event.name
        infoLabel.text = event.text
        let eventDetailsFormat = NSLocalizedString("%d People are attending", comment: "Event details: details format")
        detailsLabel.text = String(format: eventDetailsFormat, event.participants ?? 0)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        let startDate = dateFormatter.stringFromDate(event.startDate ?? NSDate())
        let endDate = dateFormatter.stringFromDate(event.endDate ?? NSDate())
        priceLabel.text = "\(startDate) - \(endDate)"
        eventImageView.setImageFromURL(event.photos?.first?.url, placeholder: UIImage(named: "eventDetailsPlaceholder"))
        
    }
    
    private lazy var dataSource: EventDetailsDataSource = { [unowned self] in
        let dataSource = EventDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    private func eventActionItems() -> [[EventActionItem]] {
        return [
            [ // 0 section
                EventActionItem(title: NSLocalizedString("Attend", comment: "Event action: Attend"), image: "eventAttend", action: .Attend),
            ],
            [ // 1 section
                EventActionItem(title: NSLocalizedString("Products on Sale", comment: "Event action: Products on Sale"), image: "productBuyProduct", action: .ProductsOnSale),
                EventActionItem(title: NSLocalizedString("Send Message", comment: "Event action: Send Message"), image: "productSendMessage", action: .SendMessage),
                EventActionItem(title: NSLocalizedString("Organizer Profile", comment: "Event action: Organizer Profile"), image: "productSellerProfile", action: .OrganizerProfile),
                EventActionItem(title: NSLocalizedString("Share", comment: "Event action: Share"), image: "eventShare", action: .Share),
                EventActionItem(title: NSLocalizedString("Terms and Information", comment: "Event action: Terms and Information"), image: "productTerms&Info", action: .TermsAndInformation),
                EventActionItem(title: NSLocalizedString("Navigate", comment: "Event action: Navigate"), image: "productNavigate", action: .Navigate)
                
                
            ],
        ]
        
    }
    
    var objectId: CRUDObjectId?
    
    private var event: Event?
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension EventDetailsViewController {
    enum EventDetailsAction: Printable {
        case Attend, ProductsOnSale, SendMessage, OrganizerProfile, Share, TermsAndInformation, Navigate
        
        var description: String {
            switch self {
            case .Attend:
                return "Attend"
            case .ProductsOnSale:
                return "Products on Sale"
            case .SendMessage:
                return "Send Message"
            case .OrganizerProfile:
                return "Organizer Profile"
            case .Share:
                return "Share"
            case .TermsAndInformation:
                return "Terms & Information"
            case .Navigate:
                return "Navigate"
            }
        }
    }
    
    
    struct EventActionItem {
        let title: String
        let image: String
        let action: EventDetailsAction
    }
}

extension EventDetailsViewController: EventDetailsActionConsumer {
    func executeAction(action: EventDetailsAction) {
        switch action {
        case .OrganizerProfile:
            if let userId = event?.author {
                let profileController = Storyboards.Main.instantiateUserProfileViewController()
                profileController.objectId = userId
                navigationController?.pushViewController(profileController, animated: true)                
            }
        default:
            Log.warning?.message("Unhandled action: \(action)")
            return
        }
    }
}

extension EventDetailsViewController {
    internal class EventDetailsDataSource: TableViewDataSource {
        
        var items: [[EventActionItem]] = []
        
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
            if let actionConsumer = parentViewController as? EventDetailsActionConsumer {
                actionConsumer.executeAction(item.action)
            }
        }
        
    }
}


