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

import BrightFutures

final class AddPostViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Message = "Message"
        case Community = "Community"
        case Photo = "Photo"
        case Title = "Title"
        case Location = "location"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Post", comment: "New post: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)

        // Message
        let messageRow = XLFormRowDescriptor(tag: Tags.Message.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        messageRow.required = true
        messageRow.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Message", comment: "New post: message")
        messageRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect message lenght",
            comment: "Add post"), regex: "^.{0,500}$"))
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
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
    
    @IBAction func cancelButtonTouched(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
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
        
        let community =  communityValue(values[Tags.Community.rawValue])
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]) {
            let getLocation = locationController().getCurrentLocation()
                view.userInteractionEnabled = false
                getLocation.zip(imageUpload).flatMap { (location: Location, urls: [NSURL]) -> Future<Post, NSError> in
                    var post = Post()
                    post.name = values[Tags.Message.rawValue] as? String
                    post.text = values[Tags.Message.rawValue] as? String
                    post.location = location
                    post.photos = urls.map { url in
                        var info = PhotoInfo()
                        info.url = url
                        return info
                    }
                    if let communityId = community {
                        return api().createCommunityPost(communityId, post: post)
                    } else {
                        return api().createUserPost(post: post)
                    }
                }.onSuccess { [weak self] (post: Post) -> ()  in
                    Log.debug?.value(post)
                    self?.sendUpdateNotification()
                    self?.performSegue(AddPostViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
        }
    }
    
}
