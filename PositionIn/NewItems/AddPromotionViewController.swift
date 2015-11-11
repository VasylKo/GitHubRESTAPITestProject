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

import BrightFutures

final class AddPromotionViewController: BaseAddItemViewController {

    private enum Tags : String {
        case Title = "Title"
        case Discount = "Discount"
        case Category = "Category"
        case StartDate = "Start date"
        case EndDate = "End date"
        case Community = "Community"
        case Photo = "Photo"
        case Location = "Location"
        case Description = "Description"
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
        let form = XLFormDescriptor(title: NSLocalizedString("Emergency", comment: "New promotion: form caption"))
        
        // General info section
        let infoGeneralSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoGeneralSection)
        // Title
        let titleRow = XLFormRowDescriptor(tag: Tags.Title.rawValue, rowType: XLFormRowDescriptorTypeText)
        titleRow.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("Title", comment: "New promotion: title")
        titleRow.required = true
        infoGeneralSection.addFormRow(titleRow)
//        // Discount
//        let priceRow = XLFormRowDescriptor(tag: Tags.Discount.rawValue, rowType: XLFormRowDescriptorTypeDecimal, title: NSLocalizedString("Discount (%)", comment: "New promotion: discount"))
//        priceRow.required = true
//        infoGeneralSection.addFormRow(priceRow)
        
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
        startDate.onChangeBlock = { [weak self] oldValue, newValue, descriptor in
            let row = self?.form.formRowWithTag(Tags.EndDate.rawValue)
            if let row = row {
                Queue.main.async { _ in
                    if let newValueDate = newValue as? NSDate,
                        let rowDate = row.value as? NSDate {
                            row.cellConfig.setObject(newValueDate, forKey: "minimumDate")
                            if rowDate.compare(newValueDate) == NSComparisonResult.OrderedAscending {
                                row.value = newValue
                            }
                            self?.reloadFormRow(row)
                    }
                }
            }
        }
        startDate.value = defaultStartDate
        startDate.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New promotion: End date"))
        endDate.value = defaultEndDate
        endDate.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        endDate.cellConfigAtConfigure["minimumDate"] = defaultStartDate
        datesSection.addFormRow(endDate)
        
        //Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Description
        let descriptionRow = XLFormRowDescriptor(tag: Tags.Description.rawValue, rowType: XLFormRowDescriptorTypeTextView, title: NSLocalizedString("Description", comment: "New promotion: description"))
        descriptionRow.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
        descriptionSection.addFormRow(descriptionRow)

        //Terms
        let termsSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(termsSection)
        termsSection.addFormRow(termsRowDescriptor(Tags.Terms.rawValue))
        
        self.form = form
    }
    
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
                    (info, urls: [NSURL]) -> Future<Promotion, NSError> in
                    let (location, shop): (Location, CRUDObjectId) = info
                    var promotion = Promotion()
                    promotion.name = values[Tags.Title.rawValue] as? String
                    promotion.discount = values[Tags.Discount.rawValue] as? Float
                    promotion.category = category
                    promotion.endDate = values[Tags.EndDate.rawValue] as? NSDate
                    promotion.startDate = values[Tags.StartDate.rawValue] as? NSDate
                    promotion.location = location
                    promotion.text = values[Tags.Description.rawValue] as? String
                    promotion.shop = shop
                    promotion.photos = urls.map { url in
                        var info = PhotoInfo()
                        info.url = url
                        return info
                    }
                    if let communityId = community {
                        return api().createCommunityPromotion(communityId, promotion: promotion)
                    } else {
                        return api().createUserPromotion(promotion)
                    }
                }.onSuccess { [weak self] (promotion: Promotion) -> ()  in
                        Log.debug?.value(promotion)
                        self?.sendUpdateNotification()
                        self?.performSegue(AddPromotionViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
                
        }
        
    }

}
