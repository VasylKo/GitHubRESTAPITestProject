//
//  MembershipMemberProfileViewController.swift
//  PositionIn
//
//  Created by ng on 2/1/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm
import CleanroomLogger

import PosInCore
import BrightFutures
import Result

import ImagePickerSheetController
import MobileCoreServices
import Photos
class MembershipMemberProfileViewController : XLFormViewController, MembershipMemberProfileViewDelegate {
    
    private let router : MembershipRouter
    
    private var headerView : MembershipMemberProfileView?
    private var userProfile: UserProfile?
    private var phoneNumber: String?
    private var validationCode: String?
    
    enum Tags : String {
        case FirstName
        case LastName
        case Email
    }
    
    //MARK: Initializers
    
    init(router: MembershipRouter) {
        self.router = router
        
        super.init(nibName: String(MembershipMemberProfileViewController.self), bundle: nil)
        
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("My Profile"))
        
        //Info section
        let infoSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        
        let firstNameRow = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name"))
        firstNameRow.required = true
        firstNameRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        firstNameRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        firstNameRow.cellConfig["textField.placeholder"] = NSLocalizedString("Required")
        infoSection.addFormRow(firstNameRow)
        
        let lastNameRow = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name"))
        lastNameRow.required = true
        lastNameRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        lastNameRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        lastNameRow.cellConfig["textField.placeholder"] = NSLocalizedString("Required")
        infoSection.addFormRow(lastNameRow)
    
        let emailRow = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("Email"))
        emailRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        emailRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        emailRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        infoSection.addFormRow(emailRow)
        
        self.form  = form
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        
        api().getMyProfile().onSuccess { [weak self] profile in
                self?.userProfile = profile
        }
    }
    
    func setupInterface() {
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(MembershipMemberProfileView.self), owner: nil, options: nil).first as? MembershipMemberProfileView {
            self.headerView = headerView
            self.tableView.tableHeaderView = headerView
            headerView.delegate = self
        }
    }
    
    
    //MARK: Target-Action
    
    func addPhoto() {
        let controller = ImagePickerSheetController(mediaType: .Image)
        controller.maximumSelection = 1
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo"), handler: { [weak self] _ in
                self?.presentImagePicker(.Camera)
            }))
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("Add %lu Photo"), $0) as String},
            handler: { [weak self] _ in
                self?.presentImagePicker(.PhotoLibrary)
            }, secondaryHandler: { [weak self] _, numberOfPhotos in
                self?.addAssets(controller.selectedImageAssets)
            }))
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
            Log.debug?.message("Cancelled")
        }))
        
        presentViewController(controller, animated: true, completion: nil)
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
        if let asset = assets.first {
             self.headerView?.configure(asset)
        }  
    }
    
}

extension MembershipMemberProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
