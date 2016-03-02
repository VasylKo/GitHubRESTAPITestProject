//
//  CallAmbulance.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 29/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import BrightFutures

class CallAmbulanceViewController: BaseAddItemViewController {
    @IBOutlet weak var sendBarButtonItem: UIBarButtonItem?
    
    private enum Tags: String {
        case Description = "Description"
        case Incedent = "Incedent"
        case Bleeding = "Bleeding"
        case Location = "Location"
        case Photo = "Photo"
    }
    
    private enum IncidentType: Int {
        case Other = 0, Fainted, Collapsed, NonResponsive, BreathingFast, Sweating, Bleeding, NotBreathing, NotTalking, Unconscious, Seizure, Choking, ChestPain
        
        static let allValues = [Other, Fainted, Collapsed, NonResponsive, BreathingFast, Sweating, Bleeding, NotBreathing, NotTalking, Unconscious, Seizure, Choking, ChestPain]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIScheme.mainThemeColor
    }
    
    override func showFormValidationError(error: NSError!) {
        if let error = error {
            showWarning(error.localizedDescription)
        }
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title:NSLocalizedString("Call Ambulance", comment: "Call Ambulance"))
        
        //Description Section
        let descriptionSection = XLFormSectionDescriptor.formSection()
        let descriptionRow = self.descriptionRowDesctiption(Tags.Description.rawValue)
        descriptionSection.addFormRow(descriptionRow)
        form.addFormSection(descriptionSection)
        
        //Incident & Location Section
        let incedentLocationSection = XLFormSectionDescriptor.formSection()
        
        let bleedingRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Bleeding.rawValue,
            rowType:XLFormRowDescriptorTypeText, title:NSLocalizedString("Where from?",
                comment: "Call Ambulance"))
        bleedingRow.hidden = true
        bleedingRow.required = true
        
        let incedentRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Incedent.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title:NSLocalizedString("Incident Type",
                comment: "Call Ambulance"))
        var selectorOptions: [XLFormOptionsObject] = []
        var counter = 1
        for value in IncidentType.allValues {
            if let incidentName = self.incedentType(value){
                let optionObject = XLFormOptionsObject(value: counter, displayText: incidentName)
                selectorOptions.append(optionObject)
            }
            counter++
        }
        incedentRow.selectorOptions = selectorOptions
        incedentRow.value = selectorOptions.first
        incedentRow.onChangeBlock = {[weak bleedingRow]   oldValue, newValue, descriptor in
            if let value = newValue as? XLFormOptionsObject, let incidentType = value.formValue() as? NSNumber {
                if ((incidentType.integerValue - 1) == IncidentType.Bleeding.rawValue) {
                    bleedingRow?.hidden = false
                }
                else {
                    bleedingRow?.hidden = true
                }
            }
        }
        incedentLocationSection.addFormRow(incedentRow)
        incedentLocationSection.addFormRow(bleedingRow)
        
        // Location
        let locationRow = locationRowDescriptor(Tags.Location.rawValue)
        incedentLocationSection.addFormRow(locationRow)
        form.addFormSection(incedentLocationSection)
        
        // Photo section
        let photoSection = XLFormSectionDescriptor.formSection()
        photoSection.addFormRow(self.photoRowDescriptor(Tags.Photo.rawValue))
        form.addFormSection(photoSection)
        
        self.form = form
    }
    
    private func incedentType(let value: IncidentType) -> String? {
        switch value {
        case .Other:
            return NSLocalizedString("Other")
        case .Fainted:
            return NSLocalizedString("Fainted")
        case .Collapsed:
            return NSLocalizedString("Collapsed")
        case .NonResponsive:
            return NSLocalizedString("Non-responsive")
        case .BreathingFast:
            return NSLocalizedString("Breathing fast")
        case .Sweating:
            return NSLocalizedString("Sweating")
        case .Bleeding:
            return NSLocalizedString("Bleeding")
        case .NotBreathing:
            return NSLocalizedString("Not breathing")
        case .NotTalking:
            return NSLocalizedString("Not talking")
        case .Unconscious:
            return NSLocalizedString("Unconscious")
        case .Seizure:
            return NSLocalizedString("Seizure")
        case .Choking:
            return NSLocalizedString("Choking")
        case .ChestPain:
            return NSLocalizedString("Chest Pain")
        }
    }
    
    @IBAction func sendButtonTouched(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        let values = formValues()
        
        if  let imageUpload = uploadAssets(values[Tags.Photo.rawValue]) {
            let getLocation = locationController().getCurrentLocation()
            view.userInteractionEnabled = false
            sendBarButtonItem?.enabled = false
            getLocation.zip(imageUpload).flatMap { (location: Location, urls: [NSURL]) -> Future<AmbulanceRequest, NSError> in
                var ambulanceRequest = AmbulanceRequest()
                ambulanceRequest.descriptionString = values[Tags.Description.rawValue] as? String
                
                if let incidentType: XLFormOptionsObject = values[Tags.Incedent.rawValue] as? XLFormOptionsObject {
                    if let incedentTypeValue = incidentType.valueData() as? NSNumber {
                        if ((incedentTypeValue.integerValue - 1) == IncidentType.Bleeding.rawValue) {
                            
                        }
                        else {
                            
                        }
                        ambulanceRequest.incidentType = incedentTypeValue
                    }
                }
                ambulanceRequest.location = location
                ambulanceRequest.photos = urls.map { url in
                    var info = PhotoInfo()
                    info.url = url
                    return info
                }
                return api().createAmbulanceRequest(ambulanceRequest).onSuccess(callback: {[weak self] ambulanceRequest in
                    let controller = Storyboards.Onboarding.instantiateAmbulanceRequestedViewControllerId()
                    controller.ambulanceRequestObjectId = ambulanceRequest.objectId
                    self?.navigationController?.pushViewController(controller, animated: true)
                    })
            }
        }
    }

    @IBAction func cancelButtonTouched(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
