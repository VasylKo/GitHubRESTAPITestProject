//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class AddProductViewController: XLFormViewController {
    private enum Tags : String {
        case Title = "title"
        case Price = "price"
        case Category = "categories"
        case StartDate = "startDate"
        case EndDate = "endDate"
        case Community = "community"
        case Photo = "photo"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }

    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("New Product", comment: "New product: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New product: title")
        titleRow.required = true
        descriptionSection.addFormRow(titleRow)
        // Price
        let priceRow = XLFormRowDescriptor(tag: Tags.Price.rawValue, rowType: XLFormRowDescriptorTypeDecimal, title: NSLocalizedString("Price ($)", comment: "New product: price"))
        descriptionSection.addFormRow(priceRow)
        
        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        // Category
        let categoryCaption = NSLocalizedString("Category", comment: "New product: category caption")
        let categoryRow = XLFormRowDescriptor(tag: Tags.Category.rawValue, rowType:XLFormRowDescriptorTypeMultipleSelector, title: categoryCaption)
        categoryRow.value = [ XLFormOptionsObject(value: 0, displayText: "Other") ]
        categoryRow.selectorTitle = categoryCaption
        categoryRow.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText: "Other"),
            XLFormOptionsObject(value: 1, displayText: "Category 1"),
            XLFormOptionsObject(value: 2, displayText: "Category 2"),
            XLFormOptionsObject(value: 3, displayText: "Category 3"),
            XLFormOptionsObject(value: 4, displayText: "Category 4"),
            XLFormOptionsObject(value: 5, displayText: "Category 5")
        ]
        infoSection.addFormRow(categoryRow)
        // Location
        // Community
        let communityCaption = NSLocalizedString("Community", comment: "New product: comunity caption")
        let communityRow = XLFormRowDescriptor(tag: Tags.Community.rawValue, rowType:XLFormRowDescriptorTypeSelectorPush, title: communityCaption)
        communityRow.selectorTitle = communityCaption
        communityRow.value =  XLFormOptionsObject(value: 0, displayText:"All")
        communityRow.selectorOptions = [
            XLFormOptionsObject(value: 0, displayText:"All"),
            XLFormOptionsObject(value: 1, displayText:"Selected"),
        ]
        infoSection.addFormRow(communityRow)
        
        
        //Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        //Photo row
        let photoRow = XLFormRowDescriptor(tag: Tags.Photo.rawValue, rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("Insert photo", comment: "New product: insert photo"))
        photoRow.cellConfig["textLabel.textColor"] = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        photoRow.action.formSelector = "didTouchPhoto:"
        photoSection.addFormRow(photoRow)

        //Dates section
        let datesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Pick-up Availability (Optional)", comment: "New product: dates section header"))
        form.addFormSection(datesSection)
        //Start date
        let startDate = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("Start date", comment: "New product: Start date"))
        startDate.value = NSDate(timeIntervalSinceNow: 60*60*24)
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New product: End date"))
        endDate.value = NSDate(timeIntervalSinceNow: 60*60*25)
        datesSection.addFormRow(endDate)

        
        
        self.form = form
    }
    

    //MARK: - Actions -
    
    func didTouchPhoto(sender: XLFormRowDescriptor) {
        self.deselectFormRow(sender)
    }
    
    @IBAction func didTapPost(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        Log.debug?.message("Should post")
    }
    


}
