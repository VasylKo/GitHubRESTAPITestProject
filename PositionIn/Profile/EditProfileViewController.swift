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
        infoSection.addFormRow(emailRow)
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
                //TODO: fill email field
                //strongSelf.emailRow.value = profile WHAT?
            }
        }
    }
    
    //First name
    lazy private var firstnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: "Edit profile: First name"))
        row.required = true
        return row
    }()
    
    //Last name
    lazy private var lastnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: "Edit profile: Last name"))
        return row
    }()
    
    // Phone
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: NSLocalizedString("Phone", comment: "Edit profile: Phone"))
        return row
        }()
    
    // Email
    lazy private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("User name", comment: "Edit profile: Email"))
        // validate the email
        row.addValidator(XLFormValidator.emailValidator())
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
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)
        
//        let community =  communityValue(values[Tags.Community.rawValue])
//        
//        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]),
//            let getLocation = locationFromValue(values[Tags.Location.rawValue]) {
//                getLocation.zip(imageUpload).flatMap { (location: Location, urls: [NSURL]) -> Future<Post, NSError> in
//                    var post = Post()
//                    post.name = values[Tags.Title.rawValue] as? String
//                    post.text = values[Tags.Message.rawValue] as? String
//                    post.location = location
//                    post.photos = urls.map { url in
//                        var info = PhotoInfo()
//                        info.url = url
//                        return info
//                    }
//                    if let communityId = community {
//                        return api().createCommunityPost(communityId, post: post)
//                    } else {
//                        return api().createUserPost(post: post)
//                    }
//                    }.onSuccess { [weak self] (post: Post) -> ()  in
//                        Log.debug?.value(post)
//                        self?.performSegue(AddPostViewController.Segue.Close)
//                }
//        }
    }
}
