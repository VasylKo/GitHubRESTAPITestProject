//
//  MembershipMemberDetailsViewController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 3/1/16.
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


class MembershipMemberDetailsViewController : BaseAddItemViewController {
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : MembershipRouter
    private var userProfile: UserProfile?
    
    enum Tags : String {
        case Gender
        case DateOfBirth
        case IDPassPortNumber
        case Location
        case PostalAddress
        case PermanentResidence
        case EducationLevel
        case Profession
    }
    
    // MARK: - Initializers
    
    init(router: MembershipRouter) {
        self.router = router
        super.init(nibName: String(MembershipMemberDetailsViewController.self), bundle: nil)
        
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Member Details"))
        
        // First section
        let firstSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(firstSection)
        
        let IDPassPortNumberRow = XLFormRowDescriptor(tag: Tags.IDPassPortNumber.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("ID/PassPort Number"))
        IDPassPortNumberRow.required = false
        IDPassPortNumberRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        firstSection.addFormRow(IDPassPortNumberRow)
        
        let genderRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Gender.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Gender"))
        genderRow.required = false
        var genderSelectorOptions: [XLFormOptionsObject] = []
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Unknown.rawValue, displayText: Gender.Unknown.description))
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Male.rawValue, displayText: Gender.Male.description))
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Female.rawValue, displayText: Gender.Female.description))
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Other.rawValue, displayText: Gender.Other.description))
        genderRow.selectorOptions = genderSelectorOptions
        genderRow.value = genderSelectorOptions.first
        genderRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        genderRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        firstSection.addFormRow(genderRow)

        let dateOfBirthRow = XLFormRowDescriptor(tag: Tags.DateOfBirth.rawValue, rowType: XLFormRowDescriptorTypeDateInline, title: NSLocalizedString("Date Of Birth"))
        dateOfBirthRow.required = false
        dateOfBirthRow.value = NSDate()
        dateOfBirthRow.cellConfig["maximumDate"] = NSDate()
        dateOfBirthRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        dateOfBirthRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        firstSection.addFormRow(dateOfBirthRow)
        
        // Second section
        let secondSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(secondSection)
        
        let locationRow = locationRowDescriptor(Tags.Location.rawValue)
        locationRow.required = false
        locationRow.title = NSLocalizedString("Location")
        locationRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        locationRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        secondSection.addFormRow(locationRow)
        
        let postalAddressRow = locationRowDescriptor(Tags.PostalAddress.rawValue)
        postalAddressRow.required = false
        postalAddressRow.title = NSLocalizedString("Postal address")
        postalAddressRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        postalAddressRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        secondSection.addFormRow(postalAddressRow)
        
        let permanentResidenceRow = XLFormRowDescriptor(tag: Tags.PermanentResidence.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Permanent Residence"))
        permanentResidenceRow.required = false
        permanentResidenceRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        permanentResidenceRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        permanentResidenceRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        secondSection.addFormRow(permanentResidenceRow)
        
        // Third section
        let thirdSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(thirdSection)
        
        let educationLevelRow = XLFormRowDescriptor(tag: Tags.EducationLevel.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Education Level"))
        educationLevelRow.required = false
        educationLevelRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        educationLevelRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        educationLevelRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        thirdSection.addFormRow(educationLevelRow)
        
        let professionRow = XLFormRowDescriptor(tag: Tags.Profession.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Profession"))
        professionRow.required = false
        professionRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        professionRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        professionRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        thirdSection.addFormRow(professionRow)
        
        self.form = form
        
        api().getMyProfile().onSuccess { [weak self] profile in
            if let strongSelf = self {
                strongSelf.userProfile = profile
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.pageView.sizeToFit()
        var frame: CGRect = self.pageView.frame
        frame.origin.x = 0
        frame.origin.y = self.view.frame.size.height - frame.size.height
        self.pageView.frame = frame
        
        self.view.tintColor = UIScheme.mainThemeColor
    }
    
    func setupInterface() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done"), style: UIBarButtonItemStyle.Plain, target: self, action: "didTapDone:")
        self.title = "Member Details"
        self.navigationItem.hidesBackButton = true
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(3)
        self.view.addSubview(pageView)
    }
    
    //MARK: Target-Action
    
    @IBAction func didTapDone(sender: AnyObject) {
        let values = formValues()
        
        if let userProfile = self.userProfile {
            if let genderRawValue = (values[Tags.Gender.rawValue] as? NSNumber)?.integerValue {
                userProfile.gender = Gender(rawValue: genderRawValue)
            }
            userProfile.dateOfBirth = values[Tags.Gender.rawValue] as? NSDate
            userProfile.passportNumber = values[Tags.DateOfBirth.rawValue] as? String
            if let locationCoordinates = (values[Tags.Location.rawValue] as? CLLocation)?.coordinate {
                var location = Location()
                location.coordinates = locationCoordinates
                userProfile.location = location
            }
            if let postalAddressCoordinates = (values[Tags.PostalAddress.rawValue] as? CLLocation)?.coordinate {
                var postalAddress = Location()
                postalAddress.coordinates = postalAddressCoordinates
                userProfile.postalAddress = postalAddress
            }
            userProfile.permanentResidence = values[Tags.PermanentResidence.rawValue] as? String
            userProfile.educationLevel = values[Tags.EducationLevel.rawValue] as? String
            userProfile.profession = values[Tags.Profession.rawValue] as? String

            api().updateMyProfile(userProfile).onSuccess(callback: { [weak self] _ in
                if let strongSelf = self {
                    strongSelf.router.showMembershipMemberCardViewController(from: strongSelf)
                }
            })
        }
    }
}