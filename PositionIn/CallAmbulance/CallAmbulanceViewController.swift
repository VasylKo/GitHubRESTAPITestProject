//
//  CallAmbulance.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 29/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class CallAmbulanceViewController: BaseAddItemViewController {

    private enum Tags: String {
        case Description = "Description"
        case Incedent = "Incedent"
        case Location = "Location"
        case Photo = "Photo"
    }
    
    private enum IncidentType: Int {
        case Medical = 0, Accident, FireInjury, HeartAttack, HeadStoke, Shock
        
        static let allValues = [Medical, Accident, FireInjury, HeartAttack, HeadStoke, Shock]
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
        descriptionRow.required = true
        descriptionSection.addFormRow(descriptionRow)
        form.addFormSection(descriptionSection)
        
        //Incident & Location Section
        let incedentLocationSection = XLFormSectionDescriptor.formSection()
        let incedentRow : XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Incedent.rawValue,
            rowType:XLFormRowDescriptorTypeSelectorPush, title:NSLocalizedString("Incedent Type",
                comment: "Call Ambulance"))
        var selectorOptions: [XLFormOptionsObject] = []
        var counter = 0
        for value in IncidentType.allValues {
            if let incidentName = self.incedentType(value){
                let optionObject = XLFormOptionsObject(value: counter, displayText: incidentName)
                selectorOptions.append(optionObject)
            }
            counter++
        }
        incedentRow.selectorOptions = selectorOptions
        incedentRow.value = selectorOptions.first
        incedentRow.required = true
        incedentLocationSection.addFormRow(incedentRow)
        
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
        case .Medical:
            return NSLocalizedString("Medical", comment: "Incedent Type")
        case .Accident:
            return NSLocalizedString("Accident", comment: "Incedent Type")
        case .FireInjury:
            return NSLocalizedString("Fire Injury", comment: "Incedent Type")
        case .HeartAttack:
            return NSLocalizedString("Heart Attack", comment: "Incedent Type")
        case .HeadStoke:
            return NSLocalizedString("Head Stoke", comment: "Incedent Type")
        case .Shock:
            return NSLocalizedString("Shock", comment: "Incedent Type")
        }
    }
    
    @IBAction func sendButtonTouched(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        self.performSegue(CallAmbulanceViewController.Segue.AmbulanceRequestedSegueId)
        
    }

    @IBAction func cancelButtonTouched(sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
