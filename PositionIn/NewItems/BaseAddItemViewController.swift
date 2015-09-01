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

import PosInCore
import BrightFutures

import ImagePickerSheetController
import MobileCoreServices
import Photos


class BaseAddItemViewController: XLFormViewController {
    
    var maximumSelectedImages: Int = 1
    
    var defaultLocation: CLLocation {
        return CLLocation(latitude: 39.1746, longitude: -107.4470)
    }
    
    func locationRowDescriptor(tag: String, withCurrentCoordinate: Bool = true) -> XLFormRowDescriptor {
        let locationRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Location", comment: "New item: location"))
        locationRow.action.formSegueClass = NSClassFromString("UIStoryboardPushSegue")
        locationRow.action.viewControllerClass = LocationSelectorViewController.self
        locationRow.valueTransformer = CLLocationValueTrasformer.self
        locationRow.value = defaultLocation
        if withCurrentCoordinate {
            locationController().getCurrentCoordinate().onSuccess { [weak locationRow] coordinate in
                locationRow?.value = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
        return locationRow
    }
    
    func locationFromValue(value: AnyObject?) -> Future<Location, NSError>? {
        if let location = value as? CLLocation {
            return locationController().reverseGeocodeCoordinate(location.coordinate)
        }
        return nil
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
        
        let emptyCommunity: Community = {
            var c = Community()
            c.objectId = CRUDObjectInvalidId
            c.name = NSLocalizedString("None", comment: "New item: empty community")
            return c
        }()
        let emptyOption = XLFormOptionsObject.formOptionsObjectWithCommunity(emptyCommunity)
        
        communityRow.value =  emptyOption
        communityRow.selectorOptions = [ emptyOption ]
        api().currentUserId().flatMap { userId in
            return api().getUserCommunities(userId)
        }.onSuccess { [weak communityRow] response in
            Log.debug?.value(response.items)
            let options = [emptyOption] + response.items.map { XLFormOptionsObject.formOptionsObjectWithCommunity($0) }
            communityRow?.selectorOptions = options
        }

        return communityRow
    }
    
    func communityValue(value: AnyObject?) -> CRUDObjectId? {
        if  let option = value as? XLFormOptionsObject,
            let communityId = option.communityId
            where communityId != CRUDObjectInvalidId {
            return communityId
        }
        return nil
    }
    
    func photoRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let photoRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeButton)
        photoRow.cellClass = UploadPhotoCell.self
        return photoRow
    }
    
    func uploadAssets(value: AnyObject?, optional: Bool = true) -> Future<[NSURL], NSError>? {
        if let assets = value as? [PHAsset] {
            return sequence( assets.map { asset in
                self.uploadDataForAsset(asset).flatMap { (let data, let dataUTI) in
                    return api().uploadImage(data, dataUTI: dataUTI)
                }
            })
        }
        return optional ? Future.succeeded([]) : nil
    }
    
    private func uploadDataForAsset(asset: PHAsset) -> Future<(NSData, String), NSError> {
        let p = Promise<(NSData, String), NSError>()
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
            switch (imageData, dataUTI) {
            case (.Some, .Some):
                p.success((imageData!, dataUTI!))
            default:
                if let error = info[PHImageErrorKey] as? NSError {
                    p.failure(error)
                } else {
                    p.failure(NetworkDataProvider.ErrorCodes.UnknownError.error())
                }
            }
        }
        return p.future
    }
    
    //MARK: - Actions -
    
    @IBAction func didTapPost(sender: AnyObject) {
        Log.error?.message("Abstract post new item")
    }

    //MARK: - Image picker -
    
    func didTouchPhoto(sender: XLFormRowDescriptor) {
        currentImageRowDescriptor = sender
        
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
        currentImageRowDescriptor?.value = assets
        currentImageRowDescriptor?.cellForFormController(self).update()
    }
    
    private var currentImageRowDescriptor: XLFormRowDescriptor?
    
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