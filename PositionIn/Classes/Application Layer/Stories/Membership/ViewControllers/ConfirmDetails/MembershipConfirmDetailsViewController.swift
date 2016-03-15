//
//  MembershipConfirmDetailsViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures
import XLForm
import Box

class MembershipConfirmDetailsViewController : XLFormViewController {
    
    //TODO: should provide user info
    
    private let router : MembershipRouter
    private var userProfile: UserProfile?
    private var countyBranches: [Community]?
    private let pageView = MembershipPageView(pageCount: 3)
    
    private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Phone", comment: ""))
        row.required = true
        row.cellConfig.setObject(UIColor.grayColor(), forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    private var firstNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: ""))
        row.required = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    private var lastNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeEmail,
            title: NSLocalizedString("Email", comment: "Confirm details: Email"))
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Required", comment: "")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    private var countyBranchRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType:XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("County Branch"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    private var plan: MembershipPlan

    //MARK: Initializers
    
    init(router: MembershipRouter, plan : MembershipPlan) {
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
        
        //Phone Section
        let phoneSection = XLFormSectionDescriptor.formSection()
        phoneRow.disabled = true
        phoneRow.value = self.userProfile?.phone
        //TODO:set value
        phoneSection.addFormRow(self.phoneRow)
        form.addFormSection(phoneSection)
        
        let infoSection = XLFormSectionDescriptor.formSection()
        
        if let firstName = self.userProfile?.firstName {
            firstNameRow.value = firstName
        }
        infoSection.addFormRow(self.firstNameRow)
        
        lastNameRow.value = self.userProfile?.lastName
        infoSection.addFormRow(self.lastNameRow)
        
        emailRow.value = self.userProfile?.email
        infoSection.addFormRow(self.emailRow)

        
        var options : Array<XLFormOptionsObject> = []
        if let countyBranches = self.countyBranches {
            for countyBranch in countyBranches {
                options.append(XLFormOptionsObject(value: countyBranch.objectId, displayText: countyBranch.name))
            }
        }
        self.countyBranchRow.selectorOptions = options
        if let countyBranch = self.userProfile?.countyBranch {
            countyBranchRow.value = XLFormOptionsObject(value: countyBranch.objectId, displayText:countyBranch.name)
        }
        infoSection.addFormRow(self.countyBranchRow)
        
        form.addFormSection(infoSection)
        
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
        
        if let countyBranch = self.countyBranchRow.value as? XLFormOptionsObject {
            if let objectId = countyBranch.formValue() as? CRUDObjectId {
                var countyBranch = Community()
                countyBranch.objectId = objectId
                self.userProfile?.countyBranch = Community(objectId: objectId)
            }
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

    }
}
