//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger
import XLForm

import BrightFutures

final class AddProductViewController: BaseAddItemViewController {
    private enum Tags : String {
        case Title = "Title"
        case Price = "Price"
        case Description = "Description"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Product", comment: "New product: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New product: title")
        titleRow.required = true
        descriptionSection.addFormRow(titleRow)
        
        //Description
        let descriptionRow = XLFormRowDescriptor(tag: Tags.Description.rawValue, rowType: XLFormRowDescriptorTypeText)
        descriptionRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Desription", comment: "New product: description")
        descriptionRow.required = true
        descriptionSection.addFormRow(descriptionRow)
        // Price
        let priceRow = XLFormRowDescriptor(tag: Tags.Price.rawValue, rowType: XLFormRowDescriptorTypeDecimal, title: NSLocalizedString("Price ($)", comment: "New product: price"))
        priceRow.required = true
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
    override func didTapPost(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)
        
        let community =  communityValue(values[Tags.Community.rawValue])
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]),
            let getLocation = locationFromValue(values[Tags.Location.rawValue]) {
                getLocation.zip(imageUpload).flatMap { (location: Location, urls: [NSURL]) -> Future<ShopItemProduct, NSError> in
                    var product = ShopItemProduct()
                    product.name = values[Tags.Title.rawValue] as? String
                    product.category = 1
                    product.price = values[Tags.Price.rawValue] as? Int
                    product.descriptionProd = values[Tags.Description.rawValue] as? String
                    product.deliveryMethod = 1
                    product.location = location
                    product.photos = urls.map { url in
                        var info = PhotoInfo()
                        info.url = url
                        return info
                    }
                    if let communityId = community {
                        return api().createCommunityProduct(communityId, product: product)
                    } else {
                        return api().createUserProduct(product: product)
                    }
                    }.onSuccess { [weak self] (product: ShopItemProduct) -> ()  in
                        Log.debug?.value(product)
                        self?.performSegue(AddProductViewController.Segue.Close)
                    }.onFailure { error in
                        Log.error?.value(error)
                }
        }
    }
}
