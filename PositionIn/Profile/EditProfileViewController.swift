//
//  EditProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

final class EditProfileViewController: BaseAddItemViewController {
    
    private enum Tags : String {
        case FirstName = "FirstName"
        case LastName = "LastName"
        case Email = "Email"
        case Phone = "Phone"
        case About = "About"
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
        let form = XLFormDescriptor(title: NSLocalizedString("Edit profile", comment: "Edit profile: form caption"))
        
        // Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)

        //Info section
        let infoSection  = XLFormSectionDescriptor.formSection()
        //First name
        let firstnameRow = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: "Edit profile: First name"))
        firstnameRow.required = true
        infoSection.addFormRow(firstnameRow)
        //Last name
        let lastnameRow = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: "Edit profile: Last name"))
        lastnameRow.required = true
        infoSection.addFormRow(lastnameRow)
        // Email
        let emailRow = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("User name", comment: "Edit profile: Email"))
        // validate the email
        emailRow.addValidator(XLFormValidator.emailValidator())
        infoSection.addFormRow(emailRow)
        // Phone
        let phoneRow = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: NSLocalizedString("Phone", comment: "Edit profile: Phone"))
        infoSection.addFormRow(phoneRow)
        
        //About me
        let aboutSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("About me", comment: "Edit profile: About me"))
        form.addFormSection(aboutSection)
        let aboutRow = XLFormRowDescriptor(tag: Tags.About.rawValue, rowType: XLFormRowDescriptorTypeTextView)
        aboutSection.addFormRow(aboutRow)
        
        
        self.form  = form
    }
    
    //MARK: Actions
    @IBAction func didTapSave(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        Log.debug?.message("Should save")
    }
}
