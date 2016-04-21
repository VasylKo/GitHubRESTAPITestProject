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
    
    private var footerButtom: EplusSIgnUpNowButton?
    private var userHasAmbulanceMembership: Bool = false
    
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
        
        api().getEPlusActiveMembership().onSuccess { [unowned self] (membershipDetails: EplusMembershipDetails) -> Void in
            self.addFooterButton(.AlreadyMember)
            self.userHasAmbulanceMembership = true
        }.onFailure { [unowned self] (error: NSError) -> Void in
            self.addFooterButton(.SignUP)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.callAmbulanceForm)
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
    
    private func sendCallAmbulanceRequest() {
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
                            if let accidentDescription = values[Tags.Bleeding.rawValue] as? String {
                                ambulanceRequest.accidentDescription = accidentDescription
                            }
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
                    
                    //Send analytics event
                    let incidentType = values[Tags.Incedent.rawValue] as? XLFormOptionsObject
                    let icnidentName = incidentType?.displayText() ?? NSLocalizedString("Can't get type")
                    trackEventToAnalytics(AnalyticCategories.ambulance, action: AnalyticActios.requestSent, label: icnidentName)
                    
                    let controller = Storyboards.Onboarding.instantiateAmbulanceRequestedViewControllerId()
                    controller.ambulanceRequestObjectId = ambulanceRequest.objectId
                    self?.navigationController?.pushViewController(controller, animated: true)
                    })
            }
        }
    }
    
    @IBAction func sendButtonTouched(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        
        if userHasAmbulanceMembership {
            sendCallAmbulanceRequest()
        } else {
            let message = "Fee may be charged to a non E-Plus members depending on the distance."
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            }
            alertController.addAction(cancelAction)
            
            let SendAction = UIAlertAction(title: "Send", style: .Default) { [weak self](action) in
                self?.sendCallAmbulanceRequest()
            }
            alertController.addAction(SendAction)
            
            self.presentViewController(alertController, animated: true) {}
        }
    }
    
    @IBAction func cancelButtonTouched(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //MARK: - Footer button
    private func addFooterButton(buttonType: EplusSIgnUpNowButton.EplusButtonType) {
        let buttonHeight = CGFloat(60)
        let button = EplusSIgnUpNowButton(eplusButtonType: buttonType)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: Selector("footerButtonTouched:"), forControlEvents: UIControlEvents.TouchUpInside)
        view.insertSubview(button, aboveSubview: tableView)
        
        //Add buttons constaraints
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: button, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: button, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonHeight)
        button.addConstraint(heightConstraint)
        view.addConstraints([bottomConstraint, trailingConstraint, leadingConstraint])
        
        footerButtom = button
    }
    
    func footerButtonTouched(sender: EplusSIgnUpNowButton) {
        if sender.type == .SignUP {
            EPlusMembershipRouterImplementation().showPlansViewController(from: self, onlyPlansInfo: true)
        } else {
            EPlusMembershipRouterImplementation().showMembershipMemberCardViewController(from: self)
        }
    }
}
