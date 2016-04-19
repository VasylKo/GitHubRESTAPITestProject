//
//  EplusMembershipConfirmDetailsViewController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/14/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures
import XLForm
import Box

class EPlusMembershipConfirmDetailsViewController : XLFormViewController {
    
    //TODO: should provide user info
    
    private let router : EPlusMembershipRouter
    private var userProfile: UserProfile?
    private var countyBranches: [Community]?
    private let pageView = MembershipPageView(pageCount: 3)
    
    private enum Tags: String {
        case Phone
        
        case FirstName
        case LastName
        case IDPassportNumber
        case Email
        
        case DateOfBirth
        case Gender
        case BloodGroup
        
        case Allergies
        
        case NumberOfDependents
        
        case SchoolName
        case NumberOfStudents
        
        case CompanyName
        case NumberOfPeople
        
        case NameOfEstate
        case HouseNumbers
        case NumberOfHouseholds
        
        case NameOfSacco
        case NumberOfSaccoPeople
    }
    
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Phone", comment: ""))
        row.required = true
        row.cellConfig.setObject(UIColor.grayColor(), forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    // First name
    lazy private var firstNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: ""))
        row.required = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    // Last name
    lazy private var lastNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // IDPassport Number
    lazy private var IDPassPortNumberRow: XLFormRowDescriptor = {
        let IDPassPortNumberRow = XLFormRowDescriptor(tag: Tags.IDPassportNumber.rawValue,
            rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("ID/Passport Number"))
        IDPassPortNumberRow.required = true
        IDPassPortNumberRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        IDPassPortNumberRow.cellConfig["textField.placeholder"] = NSLocalizedString("Required")
        return IDPassPortNumberRow
    }()
    
    // Email
    lazy private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail,
            title: NSLocalizedString("Email", comment: "Confirm details: Email"))
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Required", comment: "")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Please enter a valid email", comment: "Email validation"), regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"))
        row.required = true
        return row
    }()
    
    // Date Of Birth
    lazy private var dateOfBirthRow: XLFormRowDescriptor = {
        let dateOfBirthRow = XLFormRowDescriptor(tag: Tags.DateOfBirth.rawValue,
            rowType: XLFormRowDescriptorTypeDateInline, title: NSLocalizedString("Date Of Birth"))
        dateOfBirthRow.required = true
        dateOfBirthRow.value = nil
        dateOfBirthRow.cellConfig["maximumDate"] = NSDate()
        dateOfBirthRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        dateOfBirthRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return dateOfBirthRow
    }()
    
    // Gender
    lazy private var genderRow: XLFormRowDescriptor = {
        let genderRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Gender.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Gender"))
        genderRow.required = true
        var genderSelectorOptions: [XLFormOptionsObject] = []
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Male.rawValue, displayText: Gender.Male.description))
        genderSelectorOptions.append(XLFormOptionsObject(value: Gender.Female.rawValue, displayText: Gender.Female.description))
        genderRow.selectorOptions = genderSelectorOptions
        genderRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        genderRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return genderRow
    }()
    
    // Blood Group
    lazy private var bloodGroupRow: XLFormRowDescriptor = {
        let bloodGroupRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Gender.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Blood Group"))
        bloodGroupRow.required = false
        var selectorOptions: [XLFormOptionsObject] = []
        selectorOptions.append(XLFormOptionsObject(value: BloodGroup.GroupA.rawValue, displayText: BloodGroup.GroupA.description))
        selectorOptions.append(XLFormOptionsObject(value: BloodGroup.GroupB.rawValue, displayText: BloodGroup.GroupB.description))
        selectorOptions.append(XLFormOptionsObject(value: BloodGroup.GroupAB.rawValue, displayText: BloodGroup.GroupAB.description))
        selectorOptions.append(XLFormOptionsObject(value: BloodGroup.GroupO.rawValue, displayText: BloodGroup.GroupO.description))
        selectorOptions.append(XLFormOptionsObject(value: BloodGroup.DontKnow.rawValue, displayText: BloodGroup.DontKnow.description))
        bloodGroupRow.selectorOptions = selectorOptions
        bloodGroupRow.cellConfig["textLabel.textColor"] = UIScheme.mainThemeColor
        bloodGroupRow.cellConfig["tintColor"] = UIScheme.mainThemeColor
        return bloodGroupRow
    }()
    
    // Alergies
    lazy private var allergiesRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Allergies.rawValue, rowType: XLFormRowDescriptorTypeTextView, title: NSLocalizedString("Allergies", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = false
        return row
    }()
    
    //--- Family ---//
    
    // Number of Dependents
    lazy private var numberOfDependentsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NumberOfDependents.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Number of Dependents", comment: ""))
        
        var selectorOptions: [XLFormOptionsObject] = []
        
        // TODO: Need to refactor
        selectorOptions.append(XLFormOptionsObject(value: NSNumber(integer: 1), displayText: "1"))
        selectorOptions.append(XLFormOptionsObject(value: NSNumber(integer: 2), displayText: "2"))
        selectorOptions.append(XLFormOptionsObject(value: NSNumber(integer: 3), displayText: "3"))
        selectorOptions.append(XLFormOptionsObject(value: NSNumber(integer: 4), displayText: "4"))
        selectorOptions.append(XLFormOptionsObject(value: NSNumber(integer: 5), displayText: "5"))
        row.selectorOptions = selectorOptions
        
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()

    //--- Schools ---//
    
    // School name
    lazy private var schoolNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.SchoolName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("School name", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Number of Students
    lazy private var numberOfStudentsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NumberOfStudents.rawValue, rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("Number of Students", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()

    //--- Corporates ---//
    
    // Company name
    lazy private var companyNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.CompanyName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Company name", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Number of People
    lazy private var numberOfCompanyPeopleRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NumberOfPeople.rawValue, rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("Number of People", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    //--- Residential Estate ---//
    
    // Name of Estate
    lazy private var nameOfEstateRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NameOfEstate.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Name of Estate", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // House numbers
    lazy private var houseNumbersRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.HouseNumbers.rawValue, rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("House numbers", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Number of households
    lazy private var numberOfHouseholdsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NumberOfHouseholds.rawValue, rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("Number of households", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    //--- Sacco ---//
    
    // Name of Sacco
    lazy private var nameOfSaccoRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NameOfSacco.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Name of Sacco", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Number of People
    lazy private var numberOfSaccoPeopleRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.NumberOfSaccoPeople.rawValue, rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("Number of People", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    private var plan: EPlusMembershipPlan

    //MARK: Initializers
    
    init(router: EPlusMembershipRouter, plan : EPlusMembershipPlan) {
        self.router = router
        self.plan = plan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.membershipConfirmDetails)
    }
    
    func loadData (){
        let page = APIService.Page(start: 0, size: 100)
        
        api().getCountyBranches(page).flatMap { [weak self] (response: CollectionResponse<Community>) -> Future<UserProfile, NSError> in
            self?.countyBranches = response.items
            return api().getMyProfile()
        }.onSuccess(callback: {[weak self] userProfile in
            self?.userProfile = userProfile
            self?.initializeForm()
            self?.setupInterface()
        })
    }
    
    //MARK: Setup Interface
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    private func setupInterface() {
        self.title = NSLocalizedString("Confirm Details", comment: "")
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
            style: .Plain, target: self, action: "nextButtonTouched")
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.pageView.sizeToFit()
        self.pageView.redrawView(0)
        self.view.addSubview(pageView)
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(pageView.frame), 0)
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
    
    //MARK: Form
    
    private func initializeForm() {
        let form = XLFormDescriptor(title:NSLocalizedString("Confirm Details", comment: ""))
        
        // Phone Section
        
        let phoneSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(phoneSection)
        
        phoneRow.disabled = true
        phoneRow.value = self.userProfile?.phone
        phoneSection.addFormRow(self.phoneRow)
        
        // Info section
        
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        
        if let firstName = self.userProfile?.firstName {
            firstNameRow.value = firstName
        }
        self.firstNameRow.disabled = true
        infoSection.addFormRow(self.firstNameRow)
        
        lastNameRow.value = self.userProfile?.lastName
        self.lastNameRow.disabled = true
        infoSection.addFormRow(self.lastNameRow)
        
        emailRow.value = self.userProfile?.email
        infoSection.addFormRow(self.emailRow)
        
        
        if (plan.type == .Family || plan.type == .Individual) {
            infoSection.addFormRow(self.IDPassPortNumberRow)
            
            // Additional info section
            
            let additionalInfoSection = XLFormSectionDescriptor.formSection()
            form.addFormSection(additionalInfoSection)
            
            additionalInfoSection.addFormRow(self.dateOfBirthRow)
            dateOfBirthRow.value = userProfile?.dateOfBirth
            
            additionalInfoSection.addFormRow(self.genderRow)
            if let gender = userProfile?.gender {
                genderRow.value = XLFormOptionsObject(value: gender.rawValue, displayText: gender.description)
            }
            
            additionalInfoSection.addFormRow(self.bloodGroupRow)
            
            // Allergies
            
            let allergiesSection = XLFormSectionDescriptor.formSection()
            form.addFormSection(allergiesSection)
            
            allergiesSection.addFormRow(self.allergiesRow)
        }
        
        // Plan details section
        
        let planSetailsSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(planSetailsSection)
        
        switch plan.type {
        case .Unknown:
            break
        case .Family:
            planSetailsSection.addFormRow(self.numberOfDependentsRow)
        case .Individual:
            break
        case .Schools:
            planSetailsSection.addFormRow(self.schoolNameRow)
            planSetailsSection.addFormRow(self.numberOfStudentsRow)
        case .Corporate:
            planSetailsSection.addFormRow(self.companyNameRow)
            planSetailsSection.addFormRow(self.numberOfCompanyPeopleRow)
        case .ResidentialEstates:
            planSetailsSection.addFormRow(self.nameOfEstateRow)
            planSetailsSection.addFormRow(self.houseNumbersRow)
            planSetailsSection.addFormRow(self.numberOfHouseholdsRow)
        case .Sacco:
            planSetailsSection.addFormRow(self.nameOfSaccoRow)
            planSetailsSection.addFormRow(self.numberOfSaccoPeopleRow)
        }
        
        self.form = form
    }
    
    //MARK: Target- Action
    
    @objc func nextButtonTouched() {
        navigationItem.rightBarButtonItem?.enabled = false
        
        
        
        //TODO: add validations
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            navigationItem.rightBarButtonItem?.enabled = true
            trackEventToAnalytics(AnalyticCategories.membership, action: AnalyticActios.confirmDetailsNext, label: validationErrors.first?.localizedDescription ?? NSLocalizedString("Unknown error"))
            return
        }
        
        if let email = self.emailRow.value as? String {
            self.userProfile?.email = email
        }
        if let firstName = self.firstNameRow.value as? String {
            self.userProfile?.firstName = firstName
        }
        if let lastName = self.lastNameRow.value as? String {
            self.userProfile?.lastName = lastName
        }
        
        if let userProfile = self.userProfile {
            api().updateMyProfile(userProfile).onComplete(callback: { [unowned self] _ in
                self.router.showPaymentViewController(from: self, with: self.plan)
                self.navigationItem.rightBarButtonItem?.enabled = true
                })
        } else {
            self.router.showPaymentViewController(from: self, with: self.plan)
            navigationItem.rightBarButtonItem?.enabled = true
        }
        
        trackEventToAnalytics(AnalyticCategories.membership, action: AnalyticActios.confirmDetailsNext, label: NSLocalizedString("Success"))

    }
}
