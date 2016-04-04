//
//  GoogleAnalystHelper.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation

func trackGoogleAnalyticsEvent(categoryName: String, action: String, label: String = "", value: NSNumber? = nil) {
    let tracker = GAI.sharedInstance().defaultTracker
    let builder = GAIDictionaryBuilder.createEventWithCategory(categoryName,
        action: action, label: label, value: value)
    tracker?.send(builder.build() as [NSObject : AnyObject])
}

func trackScreenToAnalytics(name: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: name)
    let build = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
    tracker.send(build)
}


struct AnalyticsLabels {
    static let phoneVerification = NSLocalizedString("PhoneVerification")
    static let verificationCode = NSLocalizedString("VerificationCode")
    static let voiceVerificationCode = NSLocalizedString("VoiceVerificationCode")
    
    static let home = NSLocalizedString("Home")
    
    static let membershipPlanSelection = NSLocalizedString("MembershipPlanSelection")
    static let membershipPlanDetails = NSLocalizedString("MembershipPlanDetails")
    static let membershipConfirmDetails = NSLocalizedString("MembershipConfirmDetails")
    static let membershipPayment = NSLocalizedString("MembershipPayment")
    static let membershipPaymentConfirmation = NSLocalizedString("MembershipPaymentConfirmation")
    static let membershipMemberDetails = NSLocalizedString("MembershipMemberDetails")
    static let membershipCard = NSLocalizedString("MembershipCard")
    
    static let emergencyAlerts = NSLocalizedString("EmergencyAlerts")
    static let emergencyAlertDetails = NSLocalizedString("EmergencyAlertDetails")
    static let emergencyAlertDonate = NSLocalizedString("EmergencyAlertDonate")
    
    static let callAmbulanceForm = NSLocalizedString("CallAmbulanceForm")
    static let callAmbulanceRequested = NSLocalizedString("CallAmbulanceRequested")
    static let callAmbulanceConfirmed = NSLocalizedString("CallAmbulanceConfirmed")
    
    static let giveBlood = NSLocalizedString("GiveBlood")
    static let giveBloodDetails = NSLocalizedString("GiveBloodDetails")
    
    static let krcsNewsList = NSLocalizedString("KrcsNewsList")
    static let krcsNewsMap = NSLocalizedString("KrcsNewsMap")
    static let krcsNewsDetails = NSLocalizedString("KrcsNewsDetails")
  
    static let donateForm = NSLocalizedString("DonateForm")
    static let donateConfirmation = NSLocalizedString("DonateConfirmation")

    static let training = NSLocalizedString("TrainingList")
    static let trainingDetails = NSLocalizedString("TrainingDetails")

    static let event = NSLocalizedString("EventList")
    static let eventDetails = NSLocalizedString("EventDetails")

    
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
//    static let  = NSLocalizedString("")
    
    
    static let unknownScreen = NSLocalizedString("UnknownScreen")
    
    static func labelForHomeItem(homeItem: HomeItem?, suffix: String = "") -> String {
        guard let homeItem  = homeItem else {
            return unknownScreen
        }
        
        var scrennLabel: String
        
        switch homeItem {
        case .Emergency:
            scrennLabel = emergencyAlerts
        case .GiveBlood:
            scrennLabel = giveBlood
        case .Donate:
            return donateForm
        case .Training:
            scrennLabel = training
            
        default:
            scrennLabel = unknownScreen
        }
        
        return scrennLabel + suffix
    }
    
}