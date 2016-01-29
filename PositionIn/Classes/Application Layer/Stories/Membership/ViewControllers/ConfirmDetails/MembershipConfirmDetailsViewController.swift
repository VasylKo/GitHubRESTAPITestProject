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
    
    private enum Tags: String {
        case Phone = "Phone"
        case FirstName = "FirstName"
        case LastName = "LastName"
        case Email = "Email"
    }
    
    lazy private var stepCounterView: MembershipPageView = {
        let stepCounterView: MembershipPageView = MembershipPageView()
        return stepCounterView
    }()
    
    lazy private var phoneRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Phone", comment: "Confirm details: Phone name"))
        row.required = true
        row.cellConfig.setObject(UIColor.grayColor(), forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    lazy private var firstnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("First name", comment: "Confirm details: First name"))
        row.required = true
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()
    
    //Last name
    lazy private var lastnameRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Last name", comment: "Confirm details: Last name"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        row.required = true
        return row
    }()
    
    // Email
    lazy private var emailRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail,
            title: NSLocalizedString("Email", comment: "Confirm details: Email"))
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "textLabel.textColor")
        row.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        return row
    }()

    //MARK: Initializers
    
    init(router: MembershipRouter) {
        self.router = router
        super.init(nibName: String(MembershipConfirmDetailsViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeForm()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.stepCounterView.sizeToFit()
        var frame: CGRect = self.stepCounterView.frame
        frame.origin.x = 0
        frame.origin.y = self.view.frame.size.height - frame.size.height
        self.stepCounterView.frame = frame
    }
    
    //MARK: Customizing
    
    func initializeForm() {
        
        self.title = NSLocalizedString("Confirm Details", comment: "Confirm Details")
        view.tintColor = UIScheme.mainThemeColor
        
        let form = XLFormDescriptor(title:NSLocalizedString("Confirm Details", comment: "Confirm Details"))
        
        //Phone Section
        let phoneSection = XLFormSectionDescriptor.formSection()
        phoneSection.addFormRow(self.phoneRow)
        phoneRow.disabled = true
        form.addFormSection(phoneSection)
        
        let infoSection = XLFormSectionDescriptor.formSection()
        
        infoSection.addFormRow(self.firstnameRow)
        //add value
        infoSection.addFormRow(self.lastnameRow)
        //add value
        infoSection.addFormRow(self.emailRow)
        //add value
        form.addFormSection(infoSection)
        
        self.form = form
        
        self.stepCounterView.sizeToFit()
        self.stepCounterView.redrawView(0)

        self.view.addSubview(self.stepCounterView)
    }
    
}
