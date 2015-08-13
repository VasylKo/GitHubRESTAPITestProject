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

class AddPromotionViewController: BaseAddItemViewController {

    private enum Tags : String {
        case Title = "Title"
        case Discount = "Discount"
        case Category = "Category"
        case StartDate = "Start date"
        case EndDate = "End date"
        case Community = "Community"
        case Photo = "Photo"
        case Location = "Location"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Promotion", comment: "New promotion: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New promotion: title")
        titleRow.required = true
        descriptionSection.addFormRow(titleRow)
        // Discount
        let priceRow = XLFormRowDescriptor(tag: Tags.Discount.rawValue, rowType: XLFormRowDescriptorTypeDecimal, title: NSLocalizedString("Discount ($)", comment: "New promotion: discount"))
        descriptionSection.addFormRow(priceRow)
        
        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        // Category
        let categoryRow = categoryRowDescriptor(Tags.Category.rawValue)
        infoSection.addFormRow(categoryRow)
        // Location
        let locationRow = locationRowDescriptor(Tags.Location.rawValue)
        infoSection.addFormRow(locationRow)
        
        // Community
        let communityRow = communityRowDescriptor(Tags.Community.rawValue)
        infoSection.addFormRow(communityRow)
        
        
        //Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        //Photo row
        let photoRow = photoRowDescriptor(Tags.Photo.rawValue)
        photoSection.addFormRow(photoRow)
        
        
        //Dates section
        let datesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Duration", comment: "New promotion: dates section header"))
        form.addFormSection(datesSection)
        //Start date
        let startDate = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("Start date", comment: "New promotion: Start date"))
        startDate.value = NSDate(timeIntervalSinceNow: 60*60*24)
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New promotion: End date"))
        endDate.value = NSDate(timeIntervalSinceNow: 60*60*25)
        datesSection.addFormRow(endDate)
        
        self.form = form
    }
    
}
