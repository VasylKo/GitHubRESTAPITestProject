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


class MembershipMemberDetailsViewController : XLFormViewController {
    private let pageView = MembershipPageView(pageCount: 3)
    private let router : MembershipRouter
    
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
        
        let genderRow = XLFormRowDescriptor(tag: Tags.Gender.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Gender"))
        genderRow.required = false
        genderRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        genderRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        genderRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        firstSection.addFormRow(genderRow)
        
        let dateOfBirthRow = XLFormRowDescriptor(tag: Tags.DateOfBirth.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("DateOfBirth"))
        dateOfBirthRow.required = false
        dateOfBirthRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        dateOfBirthRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        dateOfBirthRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        firstSection.addFormRow(dateOfBirthRow)
        
        // Second section
        let secondSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(secondSection)
        
        let locationRow = XLFormRowDescriptor(tag: Tags.Location.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Location"))
        locationRow.required = false
        locationRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        locationRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        locationRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
        secondSection.addFormRow(locationRow)
        
        let postalAddressRow = XLFormRowDescriptor(tag: Tags.PostalAddress.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Postal address"))
        postalAddressRow.required = false
        postalAddressRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        postalAddressRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        postalAddressRow.cellConfig["textField.placeholder"] = NSLocalizedString("Optional")
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
        self.router.showMembershipMemberCardViewController(from: self)
    }
}