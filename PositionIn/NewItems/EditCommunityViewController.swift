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
import BrightFutures

final class EditCommunityViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Title = "Title"
        case Description = "Description"
        case Private = "Private"
        case Photo = "Photo"
    }
    
    var existingCommunityId: CRUDObjectId? {
        didSet {
            if let communityId = existingCommunityId {
                api().getCommunity(communityId).onSuccess { [weak self] community in
                    if let strongSelf = self {
                        strongSelf.titleRow.value = community.name
                        strongSelf.descriptionRow.value = community.communityDescription
                        strongSelf.privateRow.value = NSNumber(bool: community.closed)
                        strongSelf.tableView?.reloadData()
                        strongSelf.existingCommunity = community
                    }                    
                }
            }
        }
    }
    private var existingCommunity: Community?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Edit Community", comment: "Edit community: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        
        //Photo row
        let photoRow = photoRowDescriptor(Tags.Photo.rawValue)
        descriptionSection.addFormRow(photoRow)

        // Title
        descriptionSection.addFormRow(titleRow)
        // Description
        descriptionSection.addFormRow(descriptionRow)
        //Private
        descriptionSection.addFormRow(privateRow)
        
        self.form = form
    }
    
    lazy private var titleRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New community: title")
        row.required = true
        return row
    }()
    
    lazy private var descriptionRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Description.rawValue, rowType:XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Description", comment: "New community: description")
        return row
    }()
    
    lazy private var privateRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Private.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Private", comment: "New community: private"))
        row.cellConfig.setObject(UIColor.bt_colorWithBytesR(237, g: 27, b: 46), forKey: "switchControl.onTintColor")
        row.value = NSNumber(bool: false)
        return row
    }()
    
    //MARK: - Actions -
    override func didTapPost(sender: AnyObject) {
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
        
        if  var community = existingCommunity,
            let imageUpload = uploadAssets(values[Tags.Photo.rawValue]) {
            view.userInteractionEnabled = false
            locationController().getCurrentLocation().zip(imageUpload).flatMap {
                (location: Location, urls: [NSURL]) -> Future<Void, NSError> in
                community.name = values[Tags.Title.rawValue] as? String
                community.communityDescription = values[Tags.Description.rawValue] as? String
                let rawPrivate = values[Tags.Private.rawValue] as? NSNumber
                community.closed = rawPrivate.map { $0.boolValue} ?? true
                community.avatar = urls.first
                return api().updateCommunity(community: community)
            }.onSuccess{ [weak self] _  in
                Log.debug?.value(community)
                self?.sendUpdateNotification()
                self?.performSegue(AddCommunityViewController.Segue.Close)
            }.onFailure { error in
                showError(error.localizedDescription)
            }.onComplete { [weak self] result in
                self?.view.userInteractionEnabled = true
            }
        }
    }
}
