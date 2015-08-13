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

import MapKit

import ImagePickerSheetController
import MobileCoreServices
import Photos

class AddPostViewController: XLFormViewController {
    private enum Tags : String {
        case Title = "Title"
        case Price = "Price"
        case Category = "Category"
        case StartDate = "Start date"
        case EndDate = "End date"
        case Community = "Community"
        case Photo = "Photo"
        case Location = "Location"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Product", comment: "New product: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New product: title")
        titleRow.required = true
        descriptionSection.addFormRow(titleRow)
        // Price
        let priceRow = XLFormRowDescriptor(tag: Tags.Price.rawValue, rowType: XLFormRowDescriptorTypeDecimal, title: NSLocalizedString("Price ($)", comment: "New product: price"))
        descriptionSection.addFormRow(priceRow)
        
        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        // Category
        let categoryCaption = NSLocalizedString("Category", comment: "New product: category caption")
        let categoryRow = XLFormRowDescriptor(tag: Tags.Category.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title: categoryCaption)
        categoryRow.value = [ XLFormOptionsObject(value: 0, displayText: "Other") ]
        categoryRow.selectorTitle = categoryCaption
        categoryRow.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText: "Other"),
            XLFormOptionsObject(value: 1, displayText: "Category 1"),
            XLFormOptionsObject(value: 2, displayText: "Category 2"),
            XLFormOptionsObject(value: 3, displayText: "Category 3"),
            XLFormOptionsObject(value: 4, displayText: "Category 4"),
            XLFormOptionsObject(value: 5, displayText: "Category 5")
        ]
        infoSection.addFormRow(categoryRow)
        // Location
        let locationRow = XLFormRowDescriptor(tag: Tags.Location.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Location", comment: "New product: location"))
        locationRow.action.formSegueClass = NSClassFromString("UIStoryboardPushSegue")
        locationRow.action.viewControllerClass = LocationSelectorViewController.self
        locationRow.valueTransformer = CLLocationValueTrasformer.self
        locationRow.value = CLLocation(latitude: -33, longitude: -56)
        infoSection.addFormRow(locationRow)

        // Community
        let communityCaption = NSLocalizedString("Community", comment: "New product: comunity caption")
        let communityRow = XLFormRowDescriptor(tag: Tags.Community.rawValue, rowType:XLFormRowDescriptorTypeSelectorPush, title: communityCaption)
        communityRow.selectorTitle = communityCaption
        communityRow.value =  XLFormOptionsObject(value: 0, displayText:"All")
        communityRow.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText:"All"),
            XLFormOptionsObject(value: 1, displayText:"Selected"),
        ]
        infoSection.addFormRow(communityRow)
        
        
        //Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        //Photo row
        let photoRow = XLFormRowDescriptor(tag: Tags.Photo.rawValue, rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("Insert photo", comment: "New product: insert photo"))
        photoRow.cellConfig["textLabel.textColor"] = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        photoRow.action.formSelector = "didTouchPhoto:"
        photoSection.addFormRow(photoRow)

        //Dates section
        let datesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Pick-up Availability (Optional)", comment: "New product: dates section header"))
        form.addFormSection(datesSection)
        //Start date
        let startDate = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("Start date", comment: "New product: Start date"))
        startDate.value = NSDate(timeIntervalSinceNow: 60*60*24)
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New product: End date"))
        endDate.value = NSDate(timeIntervalSinceNow: 60*60*25)
        datesSection.addFormRow(endDate)

        
        
        self.form = form
    }
    

    //MARK: - Actions -
    
    @IBAction func didTapPost(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        Log.debug?.message("Should post")
    }
    
    //MARK: - Image picker -
    
    func didTouchPhoto(sender: XLFormRowDescriptor) {
        let controller = ImagePickerSheetController()
        controller.maximumSelection = 2
        controller.addAction(ImageAction(
            title: NSLocalizedString("Take Photo", comment: "Take Photo"),
            handler: { [weak self] _ in
                self?.presentImagePicker(.Camera)
            }))
        controller.addAction(ImageAction(
            title: NSLocalizedString("Photo Library", comment: "Photo Library"),
            secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("Add %lu Photo", comment: "Add photo"), $0) as String},
            handler: { [weak self] _ in
                self?.presentImagePicker(.PhotoLibrary)
            },
            secondaryHandler: { [weak self] _, numberOfPhotos in
                self?.addAssets(controller.selectedImageAssets)
            }))
        controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
            Log.debug?.message("Cancelled")
        }))
        
        presentViewController(controller, animated: true, completion: nil)
        self.deselectFormRow(sender)
    }
    

    
    private func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            Log.debug?.message("Presenting picker for source \(sourceType)")
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.allowsEditing = false
            picker.mediaTypes = [kUTTypeImage]
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            Log.error?.message("Unavailable source type: \(sourceType)")
        }
    }
    
    private func addAssets(assets: [PHAsset]) {
        Log.debug?.message("Select images \(assets)")
    }
    
}

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let referenceURL = info[UIImagePickerControllerReferenceURL] as? NSURL,
           let asset = PHAsset.fetchAssetsWithALAssetURLs([referenceURL], options: PHFetchOptions()).firstObject as? PHAsset {
            self.addAssets([asset])
        } else {
            Log.error?.message("Get invalid media info: \(info)")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        Log.debug?.message("Cancel image selection")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}