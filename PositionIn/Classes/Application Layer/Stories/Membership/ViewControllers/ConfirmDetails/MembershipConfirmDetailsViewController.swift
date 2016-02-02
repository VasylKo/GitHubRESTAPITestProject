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
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
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
        
        //1
        self.initializeForm()
        //2
        self.setupInterface()
    }
    
    func setupInterface() {
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
    
    func initializeForm() {
        
        let form = XLFormDescriptor(title:NSLocalizedString("Confirm Details", comment: ""))
        
        //Phone Section
        let phoneSection = XLFormSectionDescriptor.formSection()
        phoneSection.addFormRow(self.phoneRow)
        phoneRow.disabled = true
        //TODO:set value
        form.addFormSection(phoneSection)
        
        let infoSection = XLFormSectionDescriptor.formSection()
        infoSection.addFormRow(self.firstNameRow)
        //TODO:set value
        infoSection.addFormRow(self.lastNameRow)
        //TODO:set value
        infoSection.addFormRow(self.emailRow)
        //TODO:set value
        form.addFormSection(infoSection)
        
        self.form = form
    }
    
    //MARK: Target- Action
    
    func nextButtonTouched() {
        //TODO: add validations
        self.router.showPaymentViewController(from: self, with: self.plan)
    }
}
