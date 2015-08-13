//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger
import XLForm


class AddPostViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Message = "Message"
        case Community = "Community"
        case Photo = "Photo"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }

    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("New Post", comment: "New post: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Message
        let messageRow = XLFormRowDescriptor(tag: Tags.Message.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        messageRow.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Message", comment: "New post: message")
        descriptionSection.addFormRow(messageRow)

        
        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)

        // Community
        let communityRow = communityRowDescriptor(Tags.Community.rawValue)
        infoSection.addFormRow(communityRow)
        
        
        //Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        //Photo row
        let photoRow = photoRowDescriptor(Tags.Photo.rawValue)
        photoSection.addFormRow(photoRow)
        
        self.form = form
    }
    

    //MARK: - Actions -
    
    

    

    
}
