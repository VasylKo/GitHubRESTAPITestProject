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
import Box

import BrightFutures

final class AddPostViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Message = "Message"
        case PostTo = "Post to"
        case Photo = "Photo"
        case Title = "Title"
        case Location = "location"
    }
    
    var communityId: CRUDObjectId?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let communityId = self.communityId {
            api().getCommunity(communityId).onSuccess(callback: {community in
                let postToRowOptional = self.form.formRowWithTag(Tags.PostTo.rawValue)
                
                if let postToRow = postToRowOptional {
                    postToRow.value = Box(community)
                    self.tableView.reloadData()
                }
            })
        }
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
        // Community
        let postToRow = XLFormRowDescriptor(tag:Tags.PostTo.rawValue,
                                            rowType: XLFormRowDescriptorTypeSelectorPush,
                                            title: "Post to")
        postToRow.action.viewControllerClass = PostToContainerViewController.self
        postToRow.valueTransformer = PostToValueTrasformer.self
        postToRow.required = true
        descriptionSection.addFormRow(postToRow)

        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        // Location
        let locationRow = locationRowDescriptor(Tags.Location.rawValue)
        infoSection.addFormRow(locationRow)
        
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
    
    @IBAction func cancelButtonTouched() {
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
        
        var communityId: String?
        
        if let communityBox = values[Tags.PostTo.rawValue] as? Box<Community> {
            communityId = communityBox.value.objectId
        }
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]) {
            let getLocation = locationController().getCurrentLocation()
                view.userInteractionEnabled = false
                getLocation.zip(imageUpload).flatMap { (location: Location, urls: [NSURL]) -> Future<Post, NSError> in
                    var post = Post()
                    post.name = values[Tags.Message.rawValue] as? String
                    post.descriptionString = values[Tags.Message.rawValue] as? String
                    post.location = location
                    
                    if let photoUrl = urls.first {
                        post.photoURL = photoUrl.absoluteString
                    }
                    
                    if let communityId = communityId {
                        post.communityID = communityId
                        return api().createCommunityPost(post: post)
                    } else {
                        return api().createUserPost(post: post)
                    }
                }.onSuccess { [weak self] (post: Post) -> ()  in
                    Log.debug?.value(post)
                    self?.sendUpdateNotification()
                    self?.cancelButtonTouched()
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
        }
    }
    
    internal class PostToValueTrasformer : NSValueTransformer {
        
        override class func transformedValueClass() -> AnyClass {
            return NSString.self
        }
        
        override class func allowsReverseTransformation() -> Bool {
            return false
        }
        
        override func transformedValue(value: AnyObject?) -> AnyObject? {
            if let valueData: AnyObject = value {
                if let box: Box<Community> = valueData as? Box {
                    return box.value.name
                }
            }
            return nil
        }
    }
    
}
