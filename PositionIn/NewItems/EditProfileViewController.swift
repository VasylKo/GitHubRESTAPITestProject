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
import BrightFutures

final class EditProfileViewController: BaseAddItemViewController {
    
    private enum Tags : String {
        case FirstName = "FirstName"
        case LastName = "LastName"
        case Phone = "Phone"
        case About = "About"
        case Photo = "Photo"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Edit profile", comment: "Edit profile: form caption"))

        // Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        photoSection.addFormRow(photoRow)

        //Info section
        let infoSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        infoSection.addFormRow(firstnameRow)
        infoSection.addFormRow(lastnameRow)
        infoSection.addFormRow(phoneRow)
        
        //About me
        let aboutSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("About me", comment: "Edit profile: About me"))
        form.addFormSection(aboutSection)
        aboutSection.addFormRow(aboutRow)
        
        
        self.form  = form
        
        api().getMyProfile().onSuccess { [weak self] profile in
            if let strongSelf = self {
                strongSelf.firstnameRow.value = profile.firstName
                strongSelf.lastnameRow.value = profile.lastName
                strongSelf.phoneRow.value = profile.phone
                strongSelf.aboutRow.value = profile.userDescription
                strongSelf.tableView.reloadData()
                strongSelf.userProfile = profile
            }
        }
    }
    
    private var userProfile: UserProfile?
    
    //First name
    lazy private var firstnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: "Edit profile: First name"))
        row.required = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
        }()
    
    //Last name
    lazy private var lastnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: "Edit profile: Last name"))
                row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
        }()
    
    // Phone
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone,
            title: NSLocalizedString("Phone", comment: "Edit profile: Phone"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
        }()
    
    //About me
    lazy private var aboutRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.About.rawValue, rowType: XLFormRowDescriptorTypeTextView)
        return row
        }()

    //Photo
    lazy private var photoRow: XLFormRowDescriptor = { [unowned self] in
        let row = self.photoRowDescriptor(EditProfileViewController.Tags.Photo.rawValue)
        return row
        }()


    //MARK: Actions
    @IBAction override func didTapPost(sender: AnyObject) {
        if view.userInteractionEnabled == false {
            return
        }
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)
        
        if  let userProfile = userProfile,
            let avatarUpload = uploadAssets(values[Tags.Photo.rawValue]) {
                view.userInteractionEnabled = false
                userProfile.firstName = values[Tags.FirstName.rawValue] as? String
                userProfile.lastName = values[Tags.LastName.rawValue] as? String
                userProfile.phone = values[Tags.Phone.rawValue] as? String
                userProfile.userDescription = values[Tags.About.rawValue] as? String
                
                avatarUpload.flatMap { (urls: [NSURL]) -> Future<Void, NSError> in
                    userProfile.avatar = urls.first
                    return api().updateMyProfile(userProfile)
                }.onSuccess { [weak self] in
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        UserProfile.CurrentUserDidChangeNotification,
                        object: userProfile,
                        userInfo: nil
                    )
                    self?.sendUpdateNotification()
                    self?.performSegue(EditProfileViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
        } else {
            showError(NSLocalizedString("Failed to fetch user data", comment: "Edit profile: Prefetch failure"))
        }
    }
}
