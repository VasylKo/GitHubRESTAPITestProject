//
//  EditProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger
import BrightFutures
import Photos
import ImagePickerSheetController
import MobileCoreServices

final class EditProfileViewController: BaseAddItemViewController, UserProfileAvatarViewDelegate {
    private enum Tags: String {
        case Photo
        case FirstName
        case LastName
        case Email
        case Phone
        case About
        case Attachments
        case Private
        case Gender
        case DateOfBirth
        case IDPassportNumber
        case Location
        case PostalAddress
        case BranchOfChoise
        case PermanentResidence
        case EducationLevel
        case Profession
    }
    
    // MARK: - Internal properties
    internal var phoneNumber: String?
    internal var validationCode: String?
    
    // MARK: - Private properties
    private var userProfile: UserProfile?
    private var countyBranches: [Community]?
    private var headerView : UserProfileAvatarView!
    
    // Photo
    lazy private var photoRow: XLFormRowDescriptor = { [unowned self] in
        let row = self.photoRowDescriptor(EditProfileViewController.Tags.Photo.rawValue)
        return row
    }()
    
    // First name
    lazy private var firstnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name"))
        row.required = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    // Last name
    lazy private var lastnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.LastName.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Email
    lazy private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Email.rawValue,
            rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("Email"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Please enter a valid email", comment: "Email validation"), regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"))
        return row
    }()
    
    // Phone
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Phone.rawValue,
            rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("Phone"))
        row.disabled = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    // About me
    lazy private var aboutRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.About.rawValue,
            rowType: XLFormRowDescriptorTypeTextView)
        row.cellConfig["textView.placeholder"] = NSLocalizedString("Optional")
        return row
    }()
    
    
    // Gender
    lazy private var genderRow: XLFormRowDescriptor = {
        let genderRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Gender.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Gender"))
        genderRow.required = false
        var genderSelectorOptions: [XLFormOptionsObject] = []
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Male.rawValue, displayText: Gender.Male.description))
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Female.rawValue, displayText: Gender.Female.description))
        genderRow.selectorOptions = genderSelectorOptions
        genderRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        genderRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return genderRow
    }()
    
    // Date Of Birth
    lazy private var dateOfBirthRow: XLFormRowDescriptor = {
        let dateOfBirthRow = XLFormRowDescriptor(tag: Tags.DateOfBirth.rawValue,
            rowType: XLFormRowDescriptorTypeDateInline, title: NSLocalizedString("Date Of Birth"))
        dateOfBirthRow.required = false
        dateOfBirthRow.value = nil
        dateOfBirthRow.cellConfig["maximumDate"] = NSDate()
        dateOfBirthRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        dateOfBirthRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return dateOfBirthRow
    }()
    
    // IDPassport Number
    lazy private var IDPassPortNumberRow: XLFormRowDescriptor = {
        let IDPassPortNumberRow = XLFormRowDescriptor(tag: Tags.IDPassportNumber.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("ID/Passport Number"))
        IDPassPortNumberRow.required = false
        IDPassPortNumberRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        return IDPassPortNumberRow
    }()
    
    // Location
    lazy private var locationRow: XLFormRowDescriptor = { [unowned self] in
        let locationRow = self.locationRowDescriptor(Tags.Location.rawValue)
        locationRow.required = false
        locationRow.title = NSLocalizedString("Location")
        locationRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        locationRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return locationRow
    }()
    
    // Postal Address
    lazy private var postalAddressRow: XLFormRowDescriptor = { [unowned self] in
        let postalAddressRow = self.locationRowDescriptor(Tags.PostalAddress.rawValue)
        postalAddressRow.required = false
        postalAddressRow.title = NSLocalizedString("Postal Address")
        postalAddressRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        postalAddressRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return postalAddressRow
    }()
    
    // Postal Branch Of Choise
    lazy private var branchOfChoiseRow: XLFormRowDescriptor = { [unowned self] in
        let branchOfChoiseRow = XLFormRowDescriptor(tag: Tags.BranchOfChoise.rawValue, rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("County Branch of Choice"))
        branchOfChoiseRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        branchOfChoiseRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        
        return branchOfChoiseRow
    }()
    
    // Permanent Residence
    lazy private var permanentResidenceRow: XLFormRowDescriptor = { [unowned self] in
        let permanentResidenceRow = XLFormRowDescriptor(tag: Tags.PermanentResidence.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Permanent Residence"))
        permanentResidenceRow.required = false
        permanentResidenceRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        permanentResidenceRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        permanentResidenceRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        return permanentResidenceRow
    }()
    
    
    // Education Level
    lazy private var educationLevelRow: XLFormRowDescriptor = { [unowned self] in
        let educationLevelRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.EducationLevel.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Education Level"))
        educationLevelRow.required = false
        var educationLevelSelectorOptions: [XLFormOptionsObject] = []
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.PrimarySchool.rawValue, displayText: EducationLevel.PrimarySchool.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.SecondarySchool.rawValue, displayText: EducationLevel.SecondarySchool.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.HighSchool.rawValue, displayText: EducationLevel.HighSchool.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.Diploma.rawValue, displayText: EducationLevel.Diploma.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.Undergraduate.rawValue, displayText: EducationLevel.Undergraduate.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.PostGraduateDiploma.rawValue, displayText: EducationLevel.PostGraduateDiploma.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.Masters.rawValue, displayText: EducationLevel.Masters.description))
        educationLevelSelectorOptions.append(XLFormOptionsObject(value: EducationLevel.PHD.rawValue, displayText: EducationLevel.PHD.description))
        educationLevelRow.selectorOptions = educationLevelSelectorOptions
        educationLevelRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        educationLevelRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return educationLevelRow
    }()
    
    // Profession
    lazy private var professionRow: XLFormRowDescriptor = { [unowned self] in
        let professionRow = XLFormRowDescriptor(tag: Tags.Profession.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Profession"))
        professionRow.required = false
        professionRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        professionRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        professionRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        return professionRow
    } ()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        if let _ = self.phoneNumber {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"),
                style: UIBarButtonItemStyle.Plain,
                target: self,
                action: "didTapDone:")
            self.title = NSLocalizedString("My Profile")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.profileEdit)
    }
    
    // MARK: - Private functions
    private func loadData (){
        let page = APIService.Page(start: 0, size: 100)
        
        api().getCountyBranches(page).flatMap { [weak self] (response: CollectionResponse<Community>) -> Future<UserProfile, NSError> in
            self?.countyBranches = response.items
            return api().getMyProfile()
        }.onSuccess(callback: {[weak self] userProfile in
            self?.userProfile = userProfile
            self?.initializeForm()
            self?.fillFormFromUserProfileModel()
            
            if let headerView = NSBundle.mainBundle().loadNibNamed(String(UserProfileAvatarView.self), owner: nil, options: nil).first as? UserProfileAvatarView {
                self?.headerView = headerView
                self?.tableView.tableHeaderView = headerView
                headerView.delegate = self
            }
            
            if let url = self?.userProfile?.avatar {
                self?.headerView?.setAvatar(url)
            }
        })
    }
    
    private func initializeForm() {
        form = XLFormDescriptor(title: NSLocalizedString("Edit profile"))

        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        infoSection.addFormRow(firstnameRow)
        infoSection.addFormRow(lastnameRow)
        infoSection.addFormRow(emailRow)
        infoSection.addFormRow(phoneRow)
        
        // About me section
        let aboutMeSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("About Me"))
        form.addFormSection(aboutMeSection)
        aboutMeSection.addFormRow(aboutRow)
        
        // Personal info section
        let personalInfoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(personalInfoSection)
        personalInfoSection.addFormRow(genderRow)
        personalInfoSection.addFormRow(dateOfBirthRow)
        personalInfoSection.addFormRow(IDPassPortNumberRow)
        
        // Addresses section
        let addressesSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(addressesSection)
        addressesSection.addFormRow(locationRow)
        addressesSection.addFormRow(postalAddressRow)
        addressesSection.addFormRow(branchOfChoiseRow)
        addressesSection.addFormRow(permanentResidenceRow)
        
        // Education Level and profession section
        let eduAndProfessionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(eduAndProfessionSection)
        eduAndProfessionSection.addFormRow(educationLevelRow)
        eduAndProfessionSection.addFormRow(professionRow)        
        
        tableView.reloadData()
    }
    
    private func fillFormFromUserProfileModel() {
        // Init info section
        firstnameRow.value = userProfile?.firstName
        lastnameRow.value = userProfile?.lastName
        emailRow.value = userProfile?.email
        phoneRow.value = userProfile?.phone
        
        // Init about me section
        aboutRow.value = userProfile?.userDescription
        
        // Init personal info section
        if let gender = userProfile?.gender {
            genderRow.value = XLFormOptionsObject(value: gender.rawValue, displayText: gender.description)
        }
        dateOfBirthRow.value = userProfile?.dateOfBirth
        IDPassPortNumberRow.value = userProfile?.passportNumber
        
        // Init addresses section
        // locationRow
        // postalAddressRow
        
        var options : Array<XLFormOptionsObject> = []
        if let countyBranches = countyBranches {
            for countyBranch in countyBranches {
                options.append(XLFormOptionsObject(value: countyBranch.objectId, displayText: countyBranch.name))
            }
        }
        branchOfChoiseRow.selectorOptions = options
        if let countyBranch = userProfile?.countyBranch {
            branchOfChoiseRow.value = XLFormOptionsObject(value: countyBranch.objectId, displayText:countyBranch.name)
        }
        
        
        permanentResidenceRow.value = userProfile?.permanentResidence
        
        // Init education Level and profession section
        if let educationLevel = userProfile?.educationLevel {
            educationLevelRow.value = XLFormOptionsObject(value: educationLevel.rawValue, displayText: educationLevel.description)
        }
        professionRow.value = userProfile?.profession
    }
    
    private func fillUserProfileModel() {
        let values = formValues()
        Log.debug?.value(values)
        
        if let userProfile = userProfile {
            userProfile.firstName = values[Tags.FirstName.rawValue] as? String
            userProfile.lastName = values[Tags.LastName.rawValue] as? String
            userProfile.email = values[Tags.Email.rawValue] as? String
            userProfile.phone = values[Tags.Phone.rawValue] as? String
            userProfile.userDescription = values[Tags.About.rawValue] as? String
            userProfile.gender = (values[Tags.Gender.rawValue] as? XLFormOptionsObject).flatMap { $0.gender }
            userProfile.dateOfBirth = values[Tags.DateOfBirth.rawValue] as? NSDate
            userProfile.passportNumber = values[Tags.IDPassportNumber.rawValue] as? String
            // locationRow
            // postalAddressRow
            if let countyBranch = values[Tags.BranchOfChoise.rawValue]  as? XLFormOptionsObject {
                if let objectId = countyBranch.formValue() as? CRUDObjectId {
                    var countyBranch = Community()
                    countyBranch.objectId = objectId
                    userProfile.countyBranch = Community(objectId: objectId)
                }
            }
            
            userProfile.educationLevel = (values[Tags.EducationLevel.rawValue] as? XLFormOptionsObject).flatMap { $0.educationLevel }
            userProfile.profession = values[Tags.Profession.rawValue] as? String
        }
    }

    //MARK: - Actions
    @IBAction func didTapDone(sender: AnyObject) {
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
        
        api().register(username: nil, password: nil, phoneNumber: self.phoneNumber,
            phoneVerificationCode: self.validationCode,
            firstName: values[Tags.FirstName.rawValue] as? String,
            lastName: values[Tags.LastName.rawValue] as? String, email: values[Tags.Email.rawValue] as? String).onSuccess(callback: {[weak self] userProfile in
                trackEventToAnalytics("Status", action: "Click", label: "Auth Success")
                Log.info?.message("Registration done")
                
                
                if let avatarUpload = self?.uploadAssets(values[Tags.Photo.rawValue]) {
                    avatarUpload.flatMap { (urls: [NSURL]) -> Future<Void, NSError> in
                        userProfile.avatar = urls.first
                        return api().updateMyProfile(userProfile)
                    }
                }
                
                let router = MembershipRouterImplementation()
                router.showInitialViewController(from: self!)
                }).onSuccess(callback: { _ in
                    api().pushesRegistration()
                }).onFailure(callback: {_ in
                    trackEventToAnalytics("Status", action: "Click", label: "Auth Fail")
                })
    }

    @IBAction override func didTapPost(sender: AnyObject) {
        if view.userInteractionEnabled == false {
            return
        }
        
        trackEventToAnalytics(AnalyticCategories.profile, action: AnalyticActios.editDone, label: NSLocalizedString("Save"))
        
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        if let userProfile = userProfile {
            if let asset = self.headerView.asset, avatarUpload = uploadAssets(asset) {
                view.userInteractionEnabled = false
                fillUserProfileModel()
                avatarUpload.flatMap { (urls: [NSURL]) -> Future<Void, NSError> in
                    userProfile.avatar = urls.first
                    return api().updateMyProfile(userProfile)
                }.onSuccess { [weak self] in
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        UserProfile.CurrentUserDidChangeNotification,
                        object: userProfile,
                        userInfo: nil
                    )
                    self?.sendUpdateNotification()
                    self?.performSegue(EditProfileViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
            } else {
                view.userInteractionEnabled = false
                fillUserProfileModel()
                api().updateMyProfile(userProfile)
                    .onSuccess { [weak self] in
                        NSNotificationCenter.defaultCenter().postNotificationName(
                            UserProfile.CurrentUserDidChangeNotification,
                            object: userProfile,
                            userInfo: nil
                        )
                        self?.sendUpdateNotification()
                        self?.performSegue(EditProfileViewController.Segue.Close)
                    }.onFailure { error in
                        showError(error.localizedDescription)
                    }.onComplete { [weak self] result in
                        self?.view.userInteractionEnabled = true
                }
            }
        }
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
    }
    
    // MARK: Avatar Photo
    
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
    
    override func addAssets(assets: [PHAsset]) {
        if let asset = assets.first {
            self.headerView?.configure(asset)
        }
    }
    
    override func uploadAssets(value: AnyObject?, optional: Bool = true) -> Future<[NSURL], NSError>? {
        if let asset = value as? PHAsset {
            return self.uploadDataForAsset(asset).flatMap({ (let data, let dataUTI) in
                return api().uploadImage(data, dataUTI: dataUTI)
            }).map({ (let url) in
                return [url]
            })
        }
        return optional ? Future(value: []) : nil
    }
    
}
