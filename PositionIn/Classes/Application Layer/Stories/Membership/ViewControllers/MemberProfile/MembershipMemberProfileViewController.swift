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
    
    private var phoneNumber: String
    private var validationCode: String
    private let router : MembershipRouter
    
    private var headerView : MembershipMemberProfileView!
    private var userProfile: UserProfile?

    
    enum Tags : String {
        case FirstName
        case LastName
        case Email
    }
    
    //MARK: Initializers
    
    init(router: MembershipRouter, phoneNumber : String, validationCode : String) {
        self.router = router
        self.phoneNumber = phoneNumber
        self.validationCode = validationCode
        
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
        
        if api().isUserAuthorized() {
            api().getMyProfile().onSuccess { [weak self] profile in
                self?.userProfile = profile
            }
        }
    }
    
    func setupInterface() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"), style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDone:")
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.title = "My Profile"
        self.navigationItem.hidesBackButton = true
        
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
    
    @IBAction func didTapDone(sender: AnyObject) {
        if view.userInteractionEnabled == false {
            return
        }
        
        guard isFieldsValid() else {
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
        
        api().register(username: nil, password: nil, phoneNumber: self.phoneNumber,
            phoneVerificationCode: self.validationCode,
            firstName: values[Tags.FirstName.rawValue] as? String,
            lastName: values[Tags.LastName.rawValue] as? String, email: values[Tags.Email.rawValue] as? String).onSuccess(callback: {[weak self] userProfile in
            
                trackEventToAnalytics(AnalyticCategories.auth, action: AnalyticActios.userSignUp)
                Log.info?.message("Registration done")
                
                if let avatarUpload = self?.uploadAssets(self?.headerView.asset) {
                    avatarUpload.flatMap { (urls: [NSURL]) -> Future<Void, NSError> in
                        userProfile.avatar = urls.first
                        return api().updateMyProfile(userProfile)
                    }
                }
                
                let router = MembershipRouterImplementation()
                router.showInitialViewController(from: self!)
                self?.navigationController?.topViewController?.navigationItem.hidesBackButton = true
            }).onSuccess(callback: { _ in
                api().pushesRegistration()
            }).onFailure(callback: {_ in
                trackEventToAnalytics(AnalyticCategories.auth, action: AnalyticActios.userSignUpFail)
            })
    }
    
    // MARK: - Fileds vaalidatios
    private func isFieldsValid() -> Bool {
        let values = formValues()
        guard let email = values[Tags.Email.rawValue] as? String else {
            return true
        }
        
        
        let validationRules: [StringValidation.ValidationRule] = [
            (email, StringValidation.sequence([StringValidation.required(),StringValidation.email()]))]
        
        return validateInput(validationRules)
    }
    
    private func validateInput(validationRules: [StringValidation.ValidationRule]) -> Bool {
        if let validationResult = StringValidation.validate(validationRules) {
            showWarning(validationResult.error.localizedDescription)
            return false
        }
        return true
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        let validationErrors : Array<NSError> = formValidationErrors() as! Array<NSError>
        let hasErrors = validationErrors.count > 0
        
        navigationItem.rightBarButtonItem?.enabled = !hasErrors
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
    
    func uploadAssets(value: AnyObject?, optional: Bool = true) -> Future<[NSURL], NSError>? {
        if let asset = value as? PHAsset {
            return self.uploadDataForAsset(asset).flatMap({ (let data, let dataUTI) in
                return api().uploadImage(data, dataUTI: dataUTI)
            }).map({ (let url) in
                return [url]
            })
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
}
