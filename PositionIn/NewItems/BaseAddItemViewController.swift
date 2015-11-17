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
import Result

import ImagePickerSheetController
import MobileCoreServices
import Photos

import Box

class BaseAddItemViewController: XLFormViewController {
    
    //MARK: - Defaults -
    
    var preselectedCommunity: CRUDObjectId?
    
    var maximumSelectedImages: Int = 1
    
    var defaultStartDate: NSDate = {
       return NSDate(timeIntervalSinceNow: -60*60*24)
    }()
    
    var defaultEndDate: NSDate = {
        return NSDate(timeIntervalSinceNow: 60*60*24)
        }()
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    //MARK: - Descriptors -
    
    func locationRowDescriptor(tag: String, withCurrentCoordinate: Bool = true) -> XLFormRowDescriptor {
        let locationRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Location", comment: "New item: location"))
        locationRow.action.formSegueClass = NSClassFromString("UIStoryboardPushSegue")
        
        locationRow.action.viewControllerClass = LocationSelectorViewController.self
        locationRow.valueTransformer = CLLocationValueTrasformer.self
        
        locationController().getCurrentLocation().onSuccess(callback:{[weak self] location in
            locationRow.value = Box(location)
            self?.reloadFormRow(locationRow)
            })
        
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
        let categoryRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeSelectorPush, title: categoryCaption)
        categoryRow.selectorTitle = categoryCaption
        let options: [XLFormOptionObject] = ItemCategory.all().map { XLFormOptionsObject.formOptionsObjectWithItemCategory($0) }
        categoryRow.value = options.first
        categoryRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        categoryRow.selectorOptions = options
        categoryRow.onChangeBlock = {[unowned categoryRow]   oldValue, newValue, descriptor in
            if let _ = newValue as? NSNull {
                categoryRow.value = oldValue
            }
        }

        return categoryRow
    }
    
    func communityRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let communityCaption = NSLocalizedString("Community", comment: "New item: comunity caption")
        let communityRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeSelectorPush, title: communityCaption)
        communityRow.selectorTitle = communityCaption
        
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
        }.onSuccess { [weak communityRow, weak self] response in
            Log.debug?.value(response.items)
            let options = [emptyOption] + response.items.map { XLFormOptionsObject.formOptionsObjectWithCommunity($0) }
            communityRow?.selectorOptions = options
            communityRow?.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
            if  let preselectedCommunity = self?.preselectedCommunity {
                let filteredOptions = options.filter { (option: XLFormOptionsObject!) -> Bool in
                    if let communityId = option.communityId where communityId == preselectedCommunity {
                        return true
                    }
                    return false
                }
                if let value = filteredOptions.first {
                    communityRow?.value = value
                    self?.tableView?.reloadData()
                }
            }
        }

        return communityRow
    }
    
    
    func titleRowDescription(tag: String) -> XLFormRowDescriptor {
        let titleRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New item: title")
        titleRow.required = true
        titleRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect title lenght",
            comment: "Add item"), regex: "^.{0,150}$"))
        return titleRow
    }
    
    func descriptionRowDesctiption(tag: String) -> XLFormRowDescriptor {
        let descriptionRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeTextView)
        descriptionRow.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Description",
            comment: "New item: description")
        descriptionRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect description lenght",
            comment: "Add item"), regex: "^.{0,500}$"))
        return descriptionRow
    }
    
    func termsRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let row = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        row.cellConfigAtConfigure["textView.placeholder"] = NSLocalizedString("Terms & Information",
            comment: "New item: Terms & Information")
        row.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect Terms & Information lenght",
            comment: "Add event"), regex: "^.{0,500}$"))
        return row
    }
    
    func communityValue(value: AnyObject?) -> CRUDObjectId? {
        if  let option = value as? XLFormOptionsObject,
            let communityId = option.communityId
            where communityId != CRUDObjectInvalidId {
            return communityId
        }
        return nil
    }
    
    func categoryValue(value: AnyObject?) -> ItemCategory? {
        if  let option = value as? XLFormOptionsObject {
            return option.itemCatefory
        }
        return nil
    }
    
    func photoRowDescriptor(tag: String) -> XLFormRowDescriptor {
        let photoRow = XLFormRowDescriptor(tag: tag, rowType: XLFormRowDescriptorTypeButton)
        photoRow.cellClass = UploadPhotoCell.self
        return photoRow
    }
    
    func startDateRowDescription(startDateRowTag: String, endDateRowTag: String) ->XLFormRowDescriptor {
        let startDate = XLFormRowDescriptor(tag: startDateRowTag,
            rowType: XLFormRowDescriptorTypeDateTimeInline,
            title: NSLocalizedString("Start date", comment: "New event: Start date"))
        startDate.value = defaultStartDate
        startDate.onChangeBlock = { [weak self] oldValue, newValue, descriptor in
            let row = self?.form.formRowWithTag(endDateRowTag)
            if let row = row {
                Queue.main.async { _ in
                    if let newValueDate = newValue as? NSDate,
                        let rowDate = row.value as? NSDate {
                            row.cellConfig.setObject(newValueDate, forKey: "minimumDate")
                            if rowDate.compare(newValueDate) == NSComparisonResult.OrderedAscending {
                                row.value = newValue
                            }
                            self?.reloadFormRow(row)
                    }
                }
            }
        }
        return startDate
    }
    
    func uploadAssets(value: AnyObject?, optional: Bool = true) -> Future<[NSURL], NSError>? {
        if let assets = value as? [PHAsset] {
            return assets.map { asset in
                self.uploadDataForAsset(asset).flatMap { (let data, let dataUTI) in
                    return api().uploadImage(data, dataUTI: dataUTI)
                }
            }.sequence()
        }
        
        return optional ? Future(value: []) : nil
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
                if let error = info?[PHImageErrorKey] as? NSError {
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

    func sendUpdateNotification(aUserInfo: [NSObject : AnyObject]? = nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            BaseAddItemViewController.NewContentAvailableNotification,
            object: self,
            userInfo: nil
        )
    }
    
    static let NewContentAvailableNotification = "NewContentAvailableNotification"
    
    //MARK: - Image picker -
    
    func didTouchPhoto(sender: XLFormRowDescriptor) {
        currentImageRowDescriptor = sender
        
        let controller = ImagePickerSheetController(mediaType: .Image)
        controller.maximumSelection = maximumSelectedImages
        controller.addAction(ImagePickerAction(
            title: NSLocalizedString("Take Photo", comment: "Take Photo"),
            handler: { [weak self] _ in
                self?.presentImagePicker(.Camera)
            }))
        controller.addAction(ImagePickerAction(
            title: NSLocalizedString("Photo Library", comment: "Photo Library"),
            secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("Add %lu Photo", comment: "Add photo"), $0) as String},
            handler: { [weak self] _ in
                self?.presentImagePicker(.PhotoLibrary)
            },
            secondaryHandler: { [weak self] _, numberOfPhotos in
                self?.addAssets(controller.selectedImageAssets)
            }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
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
            picker.mediaTypes = [kUTTypeImage as String]
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
    
    private func fetchAssetFromPickerInfo(info: [NSObject : AnyObject]) -> Future<PHAsset, NSError> {
        let promise = Promise<PHAsset, NSError>()
        var future = promise.future

        if let referenceURL = info[UIImagePickerControllerReferenceURL] as? NSURL,
            let asset = PHAsset.fetchAssetsWithALAssetURLs([referenceURL], options: PHFetchOptions()).firstObject as? PHAsset {
                future = Future(value: asset)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var assetPlaceholder: PHObjectPlaceholder!
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                createAssetRequest.creationDate = NSDate()
                assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            }, completionHandler: { success, error in
                if success == true,
                  let asset = PHAsset.fetchAssetsWithLocalIdentifiers([assetPlaceholder.localIdentifier], options: PHFetchOptions()).firstObject as? PHAsset {
                    promise.success(asset)
                } else {
                    let e = error ?? NetworkDataProvider.ErrorCodes.ParsingError.error()
                    promise.failure(e)
                }
            })
        } else {
            Log.error?.message("Get invalid media info: \(info)")
            future = Future(error: NetworkDataProvider.ErrorCodes.InvalidResponseError.error())
        }
        return future
    }
    
}

extension BaseAddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        Log.info?.message("Did pick image")
        fetchAssetFromPickerInfo(info).onComplete { [weak self] _ in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }.onFailure { error in
            showWarning(error.localizedDescription)
        }.onSuccess { [weak self] asset in
            self?.addAssets([asset])
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        Log.info?.message("Cancel image selection")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}