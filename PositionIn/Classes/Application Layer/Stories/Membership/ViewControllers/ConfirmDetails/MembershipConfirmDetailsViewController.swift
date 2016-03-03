//
//  MembershipConfirmDetailsViewController.swift
//  PositionIn
//
//  Created by ng on 1/27/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import XLForm

class MembershipConfirmDetailsViewController : XLFormViewController {
    
    //TODO: should provide user info
    
    private let router : MembershipRouter
    private var userProfile: UserProfile?
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
    
    //Last name
    private var lastNameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: ""))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Email
    private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeEmail,
            title: NSLocalizedString("Email", comment: "Confirm details: Email"))
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Required", comment: "")
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
        api().getMyProfile().onSuccess(callback: {[weak self] userProfile in
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
