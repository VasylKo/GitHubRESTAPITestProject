//
//  AddCommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class AddCommunityViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Title = "Title"
        case Description = "Description"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Group", comment: "New community: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New community: title")
        titleRow.required = true
        descriptionSection.addFormRow(titleRow)
        // Description
        let descriptionRow = XLFormRowDescriptor(tag: Tags.Description.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        descriptionRow.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Description", comment: "New community: description")
        descriptionSection.addFormRow(descriptionRow)
        
        self.form = form
    }
    

   
}
