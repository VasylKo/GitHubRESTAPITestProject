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

final class EditProfileViewController: BaseAddItemViewController {
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
        return row
    }()
    
    // Phone
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Phone.rawValue,
            rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("Phone"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    // About me
    lazy private var aboutRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.About.rawValue,
            rowType: XLFormRowDescriptorTypeTextView)
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
        let branchOfChoiseRow = self.locationRowDescriptor(Tags.PostalAddress.rawValue)
        branchOfChoiseRow.required = false
        branchOfChoiseRow.title = NSLocalizedString("County Branch Of Choice")
        branchOfChoiseRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        branchOfChoiseRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
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
    
    
    // MARK: - Lifecycle
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
        
        if let _ = self.phoneNumber {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"),
                style: UIBarButtonItemStyle.Plain,
                target: self,
                action: "didTapDone:")
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.title = NSLocalizedString("My Profile")
        }
    }
    
    // MARK: - Private functions
    func initializeForm() {
        form = XLFormDescriptor(title: NSLocalizedString("Edit profile"))

        // Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        photoSection.addFormRow(photoRow)

        // Info section
        let infoSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        infoSection.addFormRow(firstnameRow)
        infoSection.addFormRow(lastnameRow)
        infoSection.addFormRow(emailRow)
        infoSection.addFormRow(phoneRow)
        
        // Personal info section
        let personalInfoSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(personalInfoSection)
        personalInfoSection.addFormRow(genderRow)
        personalInfoSection.addFormRow(dateOfBirthRow)
        personalInfoSection.addFormRow(IDPassPortNumberRow)
        
        // Addresses section
        let addressesSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(addressesSection)
        addressesSection.addFormRow(locationRow)
        addressesSection.addFormRow(postalAddressRow)
        addressesSection.addFormRow(branchOfChoiseRow)
        addressesSection.addFormRow(permanentResidenceRow)
        
        // Education Level and profession section
        let eduAndProfessionSection  = XLFormSectionDescriptor.formSection()
        form.addFormSection(eduAndProfessionSection)
        eduAndProfessionSection.addFormRow(educationLevelRow)
        eduAndProfessionSection.addFormRow(professionRow)        
        
        api().getMyProfile().onSuccess { [weak self] profile in
            if let strongSelf = self {
                // Init info section
                strongSelf.firstnameRow.value = profile.firstName
                strongSelf.lastnameRow.value = profile.lastName
                strongSelf.emailRow.value = profile.email
                strongSelf.phoneRow.value = profile.phone
                
                // Init personal info section
                if let gender = profile.gender {
                    strongSelf.genderRow.value = XLFormOptionsObject(value: gender.rawValue, displayText: gender.description)
                }
                strongSelf.dateOfBirthRow.value = profile.dateOfBirth
                strongSelf.IDPassPortNumberRow.value = profile.passportNumber
                
                // Init addresses section
                // locationRow
                //strongSelf.postalAddressRow.value = profile.postalAddress
                // branchOfChoiseRow
                strongSelf.permanentResidenceRow.value = profile.permanentResidence
                
                // Init education Level and profession section
                if let educationLevel = profile.educationLevel {
                    strongSelf.educationLevelRow.value = XLFormOptionsObject(value: educationLevel.rawValue, displayText: educationLevel.description)
                }
                strongSelf.professionRow.value = profile.profession
                
                
                strongSelf.tableView.reloadData()
                strongSelf.userProfile = profile
            }
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
                trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Success")
                Log.info?.message("Registration done")
                
                
                if let avatarUpload = self?.uploadAssets(values[Tags.Photo.rawValue]) {
                    avatarUpload.flatMap { (urls: [NSURL]) -> Future<Void, NSError> in
                        userProfile.avatar = urls.first
                        return api().updateMyProfile(userProfile)
                    }
                }
                
                let router : MembershipRouter = MembershipRouterImplementation()
                router.showInitialViewController(from: self!)
                }).onSuccess(callback: { _ in
                    api().pushesRegistration()
                }).onFailure(callback: {_ in
                    trackGoogleAnalyticsEvent("Status", action: "Click", label: "Auth Fail")
                })
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
        
        if  let userProfile = userProfile,
            let avatarUpload = uploadAssets(values[Tags.Photo.rawValue]) {
                view.userInteractionEnabled = false
                userProfile.firstName = values[Tags.FirstName.rawValue] as? String
                userProfile.lastName = values[Tags.LastName.rawValue] as? String
                userProfile.email = values[Tags.Email.rawValue] as? String
                userProfile.userDescription = values[Tags.About.rawValue] as? String
                
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
            showError(NSLocalizedString("Failed to fetch user data", comment: "Edit profile: Prefetch failure"))
        }
    }
    
    // MARK: XLFormViewController
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
}
