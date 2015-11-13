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
        case Quantity =  "Quantity"
        case Terms = "Terms"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("New Product", comment: "New product: form caption"))
        
        // Caption section
        let captionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(captionSection)
        // Title
        captionSection.addFormRow(self.titleRowDescription(Tags.Title.rawValue))
        
        // Price
        var currencySymbol: String = ""
        if let cs = AppConfiguration().currencyFormatter.currencySymbol {
            currencySymbol = cs
        }
        let priceRow = XLFormRowDescriptor(tag: Tags.Price.rawValue, rowType: XLFormRowDescriptorTypeDecimal,
            title: NSLocalizedString("Price (\(currencySymbol))", comment: "New product: price"))
        priceRow.required = true
        priceRow.cellConfig.setObject(UIScheme.mainThemeColor, forKey: "tintColor")
        priceRow.addValidator(XLFormRegexValidator(msg: NSLocalizedString("Incorrect price",
            comment: "Add event"), regex: "^([0-9]|[1-9][0-9]|10000)$"))
        captionSection.addFormRow(priceRow)
        
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
        
        // Quantity
        let quantityRow = XLFormRowDescriptor(tag: Tags.Quantity.rawValue, rowType: XLFormRowDescriptorTypeStepCounter, title: NSLocalizedString("Quantity", comment: "New product: Quantity"))
        quantityRow.value = 1
        quantityRow.cellConfigAtConfigure["stepControl.minimumValue"] = 1
        quantityRow.cellConfigAtConfigure["stepControl.maximumValue"] = 100
        quantityRow.cellConfigAtConfigure["stepControl.stepValue"] = 1
        quantityRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        quantityRow.cellConfigAtConfigure["currentStepValue.textColor"] = UIScheme.mainThemeColor
        infoSection.addFormRow(quantityRow)
        
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
        let startDate = startDateRowDescription(Tags.StartDate.rawValue, endDateRowTag: Tags.EndDate.rawValue)
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New product: End date"))
        endDate.value = defaultEndDate
        endDate.cellConfigAtConfigure["minimumDate"] = defaultStartDate
        datesSection.addFormRow(endDate)
        
        //Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Description
        descriptionSection.addFormRow(self.descriptionRowDesctiption(Tags.Description.rawValue))
        
        //Terms
        let termsSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(termsSection)
        termsSection.addFormRow(termsRowDescriptor(Tags.Terms.rawValue))
        
        self.form = form
    }
    
    
    //MARK: - Actions -
    override func didTapPost(sender: AnyObject) {
        if view.userInteractionEnabled == false {
            return
        }
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)
        
        let community =  communityValue(values[Tags.Community.rawValue])
        let category = categoryValue(values[Tags.Category.rawValue])
        
        let getShop: Future<CRUDObjectId, NSError>
        switch community {
        case .Some(let communityId):
            getShop = Shop.defaultCommunityShop(communityId)
        default:
            getShop = Shop.defaultUserShop()
        }

        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]),
            let getLocation = locationFromValue(values[Tags.Location.rawValue]) {
                view.userInteractionEnabled = false
                getLocation.zip(getShop).zip(imageUpload).flatMap {
                    (info, urls: [NSURL]) -> Future<Product, NSError> in
                    let (location, shop): (Location, CRUDObjectId) = info
                    var product = Product()
                    product.name = values[Tags.Title.rawValue] as? String
                    product.price = values[Tags.Price.rawValue] as? Float
                    product.text = values[Tags.Description.rawValue] as? String
                    product.quantity = (values[Tags.Quantity.rawValue] as? Double).map { Int($0) }
                    product.category = category
                    product.location = location
                    
                    //TODO: set additional values
                    product.deliveryMethod = .Unknown
                    //Start Date
                    // End Date
                    
                    product.photos = urls.map { url in
                        var info = PhotoInfo()
                        info.url = url
                        return info
                    }
                    return api().createProduct(product, inShop: shop)
                }.onSuccess { [weak self] (product: Product) -> ()  in
                    Log.debug?.value(product)
                    self?.sendUpdateNotification()
                    self?.performSegue(AddProductViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
        }
    }
}
