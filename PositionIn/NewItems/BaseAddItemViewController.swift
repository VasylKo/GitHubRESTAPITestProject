//
//  BaseAddItemViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

import CleanroomLogger
import XLForm

import CoreLocation

import ImagePickerSheetController
import MobileCoreServices
import Photos


class BaseAddItemViewController: XLFormViewController {
    
    var maximumSelectedImages: Int = 2

    
    func locationRowDescriptor(tag: String, location: CLLocation? = nil) -> XLFormRowDescriptor {
        let locationRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Location", comment: "New item: location"))
        locationRow.action.formSegueClass = NSClassFromString("UIStoryboardPushSegue")
        locationRow.action.viewControllerClass = LocationSelectorViewController.self
        locationRow.valueTransformer = CLLocationValueTrasformer.self
        locationRow.value = location ?? CLLocation(latitude: -33, longitude: -56)
        return locationRow
    }
    
    func categoryRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let categoryCaption = NSLocalizedString("Category", comment: "New item: category caption")
        let categoryRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeMultipleSelector, title: categoryCaption)
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
        return categoryRow
    }
    
    func communityRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let communityCaption = NSLocalizedString("Community", comment: "New item: comunity caption")
        let communityRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeSelectorPush, title: communityCaption)
        communityRow.selectorTitle = communityCaption
        communityRow.value =  XLFormOptionsObject(value: 0, displayText:"All")
        communityRow.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText:"All"),
            XLFormOptionsObject(value: 1, displayText:"Selected"),
        ]
        return communityRow
    }
    
    func photoRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let photoRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("Insert photo", comment: "New item: insert photo"))
        photoRow.cellConfig["textLabel.textColor"] = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        photoRow.action.formSelector = "didTouchPhoto:"
        return photoRow
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
        controller.maximumSelection = maximumSelectedImages
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

extension BaseAddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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