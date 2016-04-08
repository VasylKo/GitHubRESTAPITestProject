//
//  GoogleAnalystHelper.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation

func trackEventToAnalytics(categoryName: String, action: String, label: String = "", value: NSNumber? = nil) {
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
    
    static let krcsNews = NSLocalizedString("KrcsNews")
    static let krcsNewsList = NSLocalizedString("KrcsNewsList")
    static let krcsNewsDetails = NSLocalizedString("KrcsNewsDetails")
  
    static let donateForm = NSLocalizedString("DonateForm")
    static let donateConfirmation = NSLocalizedString("DonateConfirmation")

    static let training = NSLocalizedString("Training")
    static let trainingDetails = NSLocalizedString("TrainingDetails")

    static let event = NSLocalizedString("EventList")
    static let eventDetails = NSLocalizedString("EventDetails")

    
    static let project = NSLocalizedString("Project")
    static let projectDetails = NSLocalizedString("ProjectDetails")
    
    
    static let marketItem = NSLocalizedString("MarketItem")
    static let marketItemDetails = NSLocalizedString("MarketItemDetails")
    static let marketItemPurchase = NSLocalizedString("MarketItemPurchase")

    static let bomaHotel = NSLocalizedString("BomaHotel")
    static let bomaHotelDetails = NSLocalizedString("BomaHotelDetails")
    
    static let volunteerList = NSLocalizedString("VolunteerList")
    static let volunteerMap = NSLocalizedString("VolunteerMap")
    static let volunteerDetails = NSLocalizedString("VolunteerDetails")
    static let volunteerPostsList = NSLocalizedString("VolunteerPostsList")
    static let volunteerPostDetails = NSLocalizedString("VolunteerPostDetails")
    
    static let feed = NSLocalizedString("Feed")
    static let feedDetails = NSLocalizedString("FeedDetails")

    static let messages = NSLocalizedString("Messages")
    static let messagesNewChat = NSLocalizedString("MessagesNewChat")
    
    static let communitiesList = NSLocalizedString("CommunitiesList")
    static let communitiesMap = NSLocalizedString("CommunitiesMap")
    static let communityDetails = NSLocalizedString("CommunityDetails")
    static let communityPostsList = NSLocalizedString("CommunityPostsList")
    static let communityPostDetails = NSLocalizedString("CommunityPostDetails")

    static let peopleList = NSLocalizedString("PeopleList")
    static let peopleDetails = NSLocalizedString("PeopleDetails")
    
    static let walletList = NSLocalizedString("WalletList")
    static let walletDetails = NSLocalizedString("WalletDetails")
    static let walletDonationsDetails = NSLocalizedString("WalletDonationsDetails")
    
    static let settings = NSLocalizedString("Settings")

    static let profile = NSLocalizedString("Profile")
    static let profileEdit = NSLocalizedString("ProfileEdit")
    static let chat = NSLocalizedString("Chat")
   
    //static let  = NSLocalizedString("")

    static let mapScreen = NSLocalizedString("MapScreen")
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
        case .Projects:
            scrennLabel = project
        case .Market:
            scrennLabel = marketItem
        case .BomaHotels:
            scrennLabel = bomaHotel
        case .Volunteer:
            return volunteerPostsList

            
        default:
            scrennLabel = unknownScreen
        }
        
        return scrennLabel + suffix
    }
    
    static func labelForItemType(itemType: FeedItem.ItemType?, suffix: String = "") -> String {
    
        guard let itemType  = itemType else {
            return unknownScreen
        }
        
        var scrennLabel: String
        
        switch itemType {
        case .Emergency:
            scrennLabel = emergencyAlerts
        case .GiveBlood:
            scrennLabel = giveBlood
        case .Training:
            scrennLabel = training
        case .Project:
            scrennLabel = project
        case .Market:
            scrennLabel = marketItem
        case .BomaHotels:
            scrennLabel = bomaHotel
        case .News:
           scrennLabel = krcsNews
            
        default:
            scrennLabel = unknownScreen
        }
        
        /*
case Unknown
case Project
case Emergency
case Training
case GiveBlood
case Volunteer
case BomaHotels
case Event
case News
case Market
case Post
case Donation
*/
        return scrennLabel + suffix
    }
    
}