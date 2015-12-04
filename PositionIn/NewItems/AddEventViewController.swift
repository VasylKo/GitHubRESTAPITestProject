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

import Box
import BrightFutures

final class AddEventViewController: BaseAddItemViewController {

    private enum Tags : String {
        case Title = "Title"
        case Description = "Description"
        case Category = "Category"
        case StartDate = "Start date"
        case EndDate = "End date"
        case Community = "Community"
        case Photo = "Photo"
        case Location = "Location"
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
        let form = XLFormDescriptor(title: NSLocalizedString("New Event", comment: "New event: form caption"))
        
        // Description section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(descriptionSection)
        // Title
        descriptionSection.addFormRow(self.titleRowDescription(Tags.Title.rawValue))
        // Description
        descriptionSection.addFormRow(self.descriptionRowDesctiption(Tags.Description.rawValue))
        
        // Info section
        let infoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(infoSection)
        // Location
        let locationRow = locationRowDescriptor(Tags.Location.rawValue)
        infoSection.addFormRow(locationRow)
        // Community
        let communityRow = communityRowDescriptor(Tags.Community.rawValue)
        infoSection.addFormRow(communityRow)
        // Category
        let categoryRow = categoryRowDescriptor(Tags.Category.rawValue)
        infoSection.addFormRow(categoryRow)

        
        //Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(photoSection)
        //Photo row
        let photoRow = photoRowDescriptor(Tags.Photo.rawValue)
        photoSection.addFormRow(photoRow)
        
        
        //Dates section
        let datesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Date & Time", comment: "New event: dates section header"))
        form.addFormSection(datesSection)
        
        //Start date
        let startDate = startDateRowDescription(Tags.StartDate.rawValue, endDateRowTag: Tags.EndDate.rawValue)
        datesSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New event: End date"))
        endDate.cellConfigAtConfigure["minimumDate"] = defaultStartDate
        endDate.value = defaultEndDate
        datesSection.addFormRow(endDate)
        
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
        
        let community = communityValue(values[Tags.Community.rawValue])
        let category = categoryValue(values[Tags.Category.rawValue])
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]),
            let location: Box<Location> = values[Tags.Location.rawValue] as? Box<Location> {
                view.userInteractionEnabled = false
                imageUpload.flatMap { (urls: [NSURL]) -> Future<Event, NSError> in
                    var event = Event()
                    event.name = values[Tags.Title.rawValue] as? String
                    event.text = values[Tags.Description.rawValue] as? String
                    event.location = location.value
                    event.category = category
                    event.endDate = values[Tags.EndDate.rawValue] as? NSDate
                    event.startDate = values[Tags.StartDate.rawValue] as? NSDate
                    
                    event.photos = urls.map { url in
                        var info = PhotoInfo()
                        info.url = url
                        return info
                    }
                    if let communityId = community {
                        return api().createCommunityEvent(communityId, event: event)
                    } else {
                        return api().createUserEvent(event)
                    }
                }.onSuccess { [weak self] (event: Event) -> ()  in
                    Log.debug?.value(event)
                    self?.sendUpdateNotification()
                    self?.performSegue(AddEventViewController.Segue.Close)
                }.onFailure { error in
                    showError(error.localizedDescription)
                }.onComplete { [weak self] result in
                    self?.view.userInteractionEnabled = true
                }
        }
    }

}
