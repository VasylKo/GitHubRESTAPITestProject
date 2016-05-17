//
//  MoreInformationViewController.swift
//  PositionIn
//
//  Created by ng on 2/11/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm
import Box

class MoreInformationViewController : XLFormViewController {
    
    private enum Tags : String {
        case Link
        case Attachment
    }
    
    var attachments : [Attachment]
    var links : [NSURL]
    var newsTitle: String?
    private var shoudBounces: Bool
    var attachmentRowDescriptors : [XLFormRowDescriptor] = []
    static let singleAttacmentViewHeight: CGFloat = 150
    //MARK: Initializers
    
    init(links: [NSURL]?, attachments: [Attachment]?, newsTitle: String? = nil, bounces: Bool = true) {
        self.attachments = attachments ?? []
        self.links = links ?? []
        self.newsTitle = newsTitle
        self.shoudBounces = bounces
        super.init(nibName: nil, bundle: nil)
        self.initializeForm()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = UIScheme.mainThemeColor
        for (index, attachment) in self.attachments.enumerate() {
            let rowDescriptor = self.attachmentRowDescriptors[index]
            rowDescriptor.value = Box(attachment)
            rowDescriptor.cellForFormController(self).update()
        }
        
        self.tableView.bounces = shoudBounces
    }
    
    func initializeForm() {
        let form = XLFormDescriptor()
        
        if self.attachments.isEmpty == false {
            let attachmentsSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Attachments"))
            for attachment in self.attachments {
                let rowDescriptor = XLFormRowDescriptor(tag: Tags.Attachment.rawValue, rowType: XLFormRowDescriptorTypeMoreInformation)

                rowDescriptor.action.formBlock =  { _ in
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        let newsLabel = self.newsTitle ?? NSLocalizedString("Can't get news title")
                        let attachmentLabel = attachment.name ?? NSLocalizedString("Can't get attachment name")
                        trackEventToAnalytics(AnalyticCategories.feedNews, action: AnalyticActios.openAttachment, label: newsLabel + " - " + attachmentLabel)
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        //type pdf
                        if attachment.type?.containsString("pdf") == true {
                            let controller = WebViewController(nibName: "WebViewController", bundle: nil)
                            controller.contentURL = attachment.url
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        else if let url = attachment.url {
                            OpenApplication.Safari(with: url)
                        }
                    }
                }
                self.attachmentRowDescriptors.append(rowDescriptor)
                attachmentsSection.addFormRow(rowDescriptor)
            }
            form.addFormSection(attachmentsSection)
        }
        
        if self.links.isEmpty == false {
            let linksSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Links"))
            for link in self.links {
                let rowDescriptor = XLFormRowDescriptor(tag: Tags.Link.rawValue, rowType: XLFormRowDescriptorTypeButton)
                rowDescriptor.cellConfig["textLabel.text"] = link.absoluteString
                rowDescriptor.cellConfig["textLabel.textAlignment"] = Int(0)
                rowDescriptor.action.formBlock =  { _ in
                    let newsLabel = self.newsTitle ?? NSLocalizedString("Can't get news title")
                    let linkLabel = link.absoluteString
                    trackEventToAnalytics(AnalyticCategories.feedNews, action: AnalyticActios.openLink, label: newsLabel + " - " + linkLabel)
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        OpenApplication.Safari(with: link)
                    }
                }
                linksSection.addFormRow(rowDescriptor)
            }
            form.addFormSection(linksSection)
        }
        
        self.form = form
    }
    
}