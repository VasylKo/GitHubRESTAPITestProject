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
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        title = NSLocalizedString("Event", comment: "Event details: title")
        dataSource.items = eventActionItems()
        dataSource.configureTable(actionTableView)
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.eventDetails)
    }
    
    private func reloadData() {
        if let objectId = objectId {
            api().getEvent(objectId).onSuccess { [weak self] event in
                if let strongSelf = self {
                    strongSelf.didReceiveEventDetails(event)
                    strongSelf.dataSource.items = strongSelf.eventActionItems()
                    strongSelf.dataSource.configureTable(strongSelf.actionTableView)
                    
                    //If there is only 1 attachment, thant show it on current screen
                    if let numberOfAttachments = strongSelf.event?.numberOfAttachments where numberOfAttachments == 1 {
                        strongSelf.actionTableViewHeightConstraint.constant = strongSelf.actionTableView.contentSize.height
                        strongSelf.addAttachmentSection()
                    } else {
                        //adjust scroll view content size based on table view height
                        let scrollViewBottomSpaceHeight: CGFloat = 20
                        strongSelf.actionTableViewHeightConstraint.constant = strongSelf.actionTableView.contentSize.height + scrollViewBottomSpaceHeight
                    }
                }
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
        
        let image = UIImage(named: "eventDetailsPlaceholder")
        
        let startDate = dateFormatter.stringFromDate(event.startDate ?? NSDate())
        let endDate = dateFormatter.stringFromDate(event.endDate ?? NSDate())
        priceLabel.text = "\(startDate) - \(endDate)"
        eventImageView.setImageFromURL(self.event?.imageURL, placeholder: image)
        
        if event.location?.coordinates != nil {
            self.dataSource.items = self.eventActionItems()
            self.dataSource.configureTable(self.actionTableView)
        }
    }
    
    private func addAttachmentSection() {
        attechmentSectionHeightConstraint.constant = MoreInformationViewController.singleAttacmentViewHeight
        let moreInformationViewController = MoreInformationViewController(links: event?.links, attachments: event?.attachments, bounces: false)
        let attachmentsView = moreInformationViewController.view
        attechmentSectionView.addSubview(attachmentsView)
    }
    
    private lazy var dataSource: EventDetailsDataSource = { [unowned self] in
        let dataSource = EventDetailsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    private func eventActionItems() -> [[EventActionItem]] {
        var isAttend = false
        var title = "Attend"
        if let attend = self.event?.isAttending {
            isAttend = attend
            title = attend ? "Attending" : "Attend"
        }
        let zeroSection = [ // 0 section
            EventActionItem(title: NSLocalizedString(title, comment: "Event action: Attend"), image: "eventAttend", attend:isAttend ,
                action: .Attend)
        ]
        
        var firstSection = [EventActionItem]() // 1 section
        
        if self.author?.objectId != api().currentUserId() {
            firstSection.append(EventActionItem(title: NSLocalizedString("Send Message", comment: "Event action: Send Message"), image: "productSendMessage", action: .SendMessage))
            firstSection.append(EventActionItem(title: NSLocalizedString("Organizer Profile", comment: "Event action: Organizer Profile"),
                image: "productSellerProfile", action: .OrganizerProfile))
        }
        
        if self.event?.location != nil {
            firstSection.append(EventActionItem(title: NSLocalizedString("Navigate", comment: "Event action: Navigate"), image: "productNavigate", action: .Navigate))
        }
        if let numberOfAttachments = event?.numberOfAttachments where numberOfAttachments > 1 {
            firstSection.append(EventActionItem(title: NSLocalizedString("Attachments"), image: "productTerms&Info", action: .MoreInformation))
        }
        
        return [zeroSection, firstSection]
    }
    
    var objectId: CRUDObjectId?
    var author: ObjectInfo?
    
    private var event: Event?
    
    @IBOutlet private weak var actionTableView: UITableView!
    @IBOutlet weak var actionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet weak var attechmentSectionView: UIView!
    @IBOutlet weak var attechmentSectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
}

extension EventDetailsViewController {
    enum EventDetailsAction: CustomStringConvertible {
        case Attend, SendMessage, OrganizerProfile, TermsAndInformation, Navigate, MoreInformation
        
        var description: String {
            switch self {
            case .Attend:
                return "Attend"
            case .SendMessage:
                return "Send Message"
            case .OrganizerProfile:
                return "Organizer Profile"
            case .TermsAndInformation:
                return "Terms & Information"
            case .Navigate:
                return "Navigate"
            case .MoreInformation:
                return "More Information"
            }
        }
    }
    
    
    struct EventActionItem {
        let title: String
        let image: String
        var attend: Bool = false
        let action: EventDetailsAction
        
        
        init(title: String, image: String, attend: Bool = false, action: EventDetailsAction) {
            self.title = title
            self.image = image
            self.attend = attend
            self.action = action
        }
    }
}

extension EventDetailsViewController: EventDetailsActionConsumer {
    func executeAction(action: EventDetailsAction) {
        switch action {
        case .OrganizerProfile:
            if let author = author {
                let profileController = Storyboards.Main.instantiateUserProfileViewController()
                profileController.objectId = author.objectId
                navigationController?.pushViewController(profileController, animated: true)                
            }
        case .SendMessage:
            if let author = author {
                showChatViewController(author.objectId)
            }
        case .Attend :
            if api().isUserAuthorized() {
                var isAttend = false
                if let attend = self.event?.isAttending {
                    isAttend = attend
                }
                if let event = self.event {
                    api().attendEvent(event.objectId, attend:!isAttend).onSuccess(callback: {
                        self.reloadData()
                    })
                }

            }
        case .MoreInformation:
            if self.event?.links?.isEmpty == false || self.event?.attachments?.isEmpty == false {
                let moreInformationViewController = MoreInformationViewController(links: self.event?.links, attachments: self.event?.attachments)
                self.navigationController?.pushViewController(moreInformationViewController, animated: true)
            }
        case .Navigate:
            if let coordinates = self.event?.location?.coordinates {
                OpenApplication.appleMap(with: coordinates)
            } else {
                Log.error?.message("coordinates missed")
            }
        default:
            Log.warning?.message("Unhandled action: \(action)")
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
            if indexPath.section == 0 {
                return AttendEventCell.reuseId()
            }
            else {
                return ActionCell.reuseId()
            }
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let item = items[indexPath.section][indexPath.row]
            var model: TableViewCellModel
            if indexPath.section == 0 {
                model = TableViewCellAttendEventModel(title: item.title, attendEvent: item.attend)
            }
            else {
                model = TableViewCellImageTextModel(title: item.title, imageName: item.image)
            }

            return model
        }
        
        @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 1 {
                return 50
            }
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        override func nibCellsId() -> [String] {
            return [ActionCell.reuseId(), AttendEventCell.reuseId()]
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