//
//  SettingsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class SettingsViewController: XLFormViewController {
    
    private enum Tags : String {
        case Header = "Header"
        case ChangePassword = "Change Password"
        case ContactSupport = "Contact Support"
        case TermsConditions = "Terms & Conditions"
        case SignOut = "Sign Out"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawerButtonVisible = true
        self.initializeForm()
        
        self.versionLabel.text = AppConfiguration().appVersion
        self.view.addSubview(self.versionLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.scrollEnabled = (self.tableView.frame.size.height < self.tableView.contentSize.height)
    }
    
    private func initializeForm() {
        let settingCellDescription = "SettingsCell"
        
        XLFormViewController.cellClassesForRowDescriptorTypes().setObject("PositionIn.SettingsHeaderCell",
            forKey: settingCellDescription)
        
        var form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "Settings")
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.Header.rawValue, rowType:  settingCellDescription)
        section.addFormRow(row)
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.ChangePassword.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title:Tags.ChangePassword.rawValue)
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.ContactSupport.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title:Tags.ContactSupport.rawValue)
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.TermsConditions.rawValue,
            rowType: XLFormRowDescriptorTypeSelectorPush, title:Tags.TermsConditions.rawValue)
        section.addFormRow(row)
        
        if (api().isUserAuthorized()) {
            section = XLFormSectionDescriptor.formSection()
            form.addFormSection(section)
            
            row = XLFormRowDescriptor(tag: Tags.SignOut.rawValue,
                rowType: XLFormRowDescriptorTypeButton, title:Tags.SignOut.rawValue)
            row.action.formBlock = {[weak self](sender: XLFormRowDescriptor!) -> Void in
                api().logout().onComplete {_ in
                    self?.sideBarController?.executeAction(.Login)
                }
            }
            row.cellConfig.setObject(UIColor.bt_colorWithBytesR(181, g: 51, b: 59), forKey: "textLabel.textColor")
            row.cellConfig.setObject(NSTextAlignment.Center.rawValue, forKey:"textLabel.textAlignment");
            
            section.addFormRow(row)
        }
        
        self.form = form;
    }
    
    @IBOutlet private var versionLabel: UILabel!
        
    @IBAction func showMainMenu(sender: AnyObject) {
        sideBarController?.setDrawerState(.Opened, animated: true)
    }
    
    var drawerButtonVisible: Bool = false {
        didSet {
            let (backVisible: Bool, leftItem: UIBarButtonItem?) = {
                return self.drawerButtonVisible
                    ? (true, self.drawerBarButtonItem())
                    : (false, nil)
                
                }()
            self.navigationItem.hidesBackButton = backVisible
            self.navigationItem.leftBarButtonItem = leftItem
        }
    }
    
    func drawerBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "MainMenuIcon")!, style: .Plain, target: self, action: "showMainMenu:")
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(indexPath.compare(NSIndexPath(forRow: 0, inSection: 0)) == NSComparisonResult.OrderedSame)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
