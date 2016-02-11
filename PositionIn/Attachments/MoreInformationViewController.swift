//
//  MoreInformationViewController.swift
//  PositionIn
//
//  Created by ng on 2/11/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm

class MoreInformationViewController : XLFormViewController {
    
    private enum Tags : String {
        case Link
        case Attachment
    }
    
    var attachments : [Attachment]
    var links : [NSURL]
    
    //MARK: Initializers
    
    init(links: [NSURL]?, attachments: [Attachment]?) {
        self.attachments = attachments ?? []
        self.links = links ?? []
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
    }
    
    func initializeForm() {
        let form = XLFormDescriptor()
        
        if self.attachments.isEmpty == false {
            let attachmentsSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Attachments"))
            for attachment in self.attachments {
                let rowDescriptor = XLFormRowDescriptor(tag: Tags.Attachment.rawValue, rowType: XLFormRowDescriptorTypeButton)
                rowDescriptor.cellConfig["textLabel.text"] = attachment.name
                rowDescriptor.cellConfig["textLabel.textAlignment"] = Int(0)
                rowDescriptor.cellConfig["textLabel.textColor"] = UIColor.blackColor()
                rowDescriptor.cellConfig["imageView.image"] = UIImage(named: "home_news")
                rowDescriptor.action.formBlock =  { _ in
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        if let url = attachment.url {
                            OpenApplication.Safari(with: url)
                        }
                    }
                }
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