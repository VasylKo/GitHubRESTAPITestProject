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

final class AddCommunityViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Title = "Title"
        case Description = "Description"
        case Private = "Private"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Community", comment: "New community: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        
        //Photo row
        let photoRow = photoRowDescriptor(Tags.Photo.rawValue)
        descriptionSection.addFormRow(photoRow)

        // Title
        descriptionSection.addFormRow(self.titleRowDescription(Tags.Title.rawValue))
        // Description
        descriptionSection.addFormRow(self.descriptionRowDesctiption(Tags.Description.rawValue))
        
        let privateRow = XLFormRowDescriptor(tag: Tags.Private.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Private", comment: "New community: private"))
        privateRow.value = NSNumber(bool: false)
        descriptionSection.addFormRow(privateRow)

        
        self.form = form
    }
    
    
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
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]) {
            view.userInteractionEnabled = false
            locationController().getCurrentLocation().zip(imageUpload).flatMap {
                (location: Location, urls: [NSURL]) -> Future<Community, NSError> in
                var community = Community()
                community.name = values[Tags.Title.rawValue] as? String
                community.communityDescription = values[Tags.Description.rawValue] as? String
                let rawPrivate = values[Tags.Private.rawValue] as? NSNumber
                community.isPrivate = rawPrivate.map { $0.boolValue} ?? true
                community.avatar = urls.first

                return api().createCommunity(community: community)
            }.onSuccess{ [weak self] community  in
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
