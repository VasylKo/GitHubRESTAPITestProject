//
//  MembershipPlansManager.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

enum PlanType: Int {
    case Individual, Corporate
}

enum IndividualPlans: Int {
    case Guest = 0, SchoolMember, YouthMember, OrdinaryMember, LifeMember
    
    static func benefits(plan: IndividualPlans) -> [String] {
        switch plan {
        case Guest:
            return []
        case SchoolMember:
            return ["Participate in KRCS youth club activities in school/college",
                "Participate in localizing and implementation of the four part youth program",
                "Participate in the formulation of strategies for the youth club"]
        case YouthMember:
            return ["Vote to elect and to be elected as members of the different committees and boards within the Kenyan Red Cross Society governance structure.",
                "Linking society with resourceful strategic partnerships"]
        case OrdinaryMember:
            return ["Vote to elect and to be elected as members of the different committees and boards within the Kenyan Red Cross Society governance structure",
                "Invitations to attend special events, e.g., Life Members Day, KRC Gala, World Red Cross Day",
                "Participate in decision making, policy formulation and constitutional making/review",
                "Linking the society with resourceful strategic partnerships"]
        case LifeMember:
            return ["Discount of KRCS related merchandise to partners",
                "Up to 5% discount for one year membership at EPlus",
                "Up to 15% discount at the Boma",
                "Invitations to attend special events, e.g., Life Members Day, KRC Gala, World Red Cross Day",
                "Up-to-date information on KRCS operations through e-mails such as KRC E-news",
                "Update on emergency precautions"
            ]
        }
    }
    
    static func individualIconImage(plan: IndividualPlans) -> UIImage? {
        switch plan {
        case Guest:
            return UIImage(named: "ic_guest")
        case SchoolMember:
            return UIImage(named: "ic_school")
        case YouthMember:
            return UIImage(named: "ic_user18")
        case OrdinaryMember:
            return UIImage(named: "ic_user")
        case LifeMember:
            return UIImage(named: "ic_lifetime")
        }
    }
    
    static func title(plan: IndividualPlans) -> String? {
        switch plan {
        case Guest:
            return NSLocalizedString("Continue as Guest", comment: "Membership")
        case SchoolMember:
            return NSLocalizedString("Youth Member in School", comment: "Membership")
        case YouthMember:
            return NSLocalizedString("Youth Member Over 18", comment: "Membership")
        case OrdinaryMember:
            return NSLocalizedString("Ordinary Member", comment: "Membership")
        case LifeMember:
            return NSLocalizedString("Life Member", comment: "Membership")
        }
    }
    
    static func price(plan: IndividualPlans) -> Float? {
        switch plan {
        case Guest:
            return nil
        case SchoolMember:
            return 100.0
        case YouthMember:
            return 500.0
        case OrdinaryMember:
            return 1000.0
        case LifeMember:
            return 5000.0
        }
    }
    
    static func description(plan: IndividualPlans) -> String? {
        switch plan {
        case Guest:
            return NSLocalizedString("Free", comment: "Membership")
        case SchoolMember:
            return NSLocalizedString("KES 100 Annualy", comment: "Membership")
        case YouthMember:
            return NSLocalizedString("KES 500 Annualy", comment: "Membership")
        case OrdinaryMember:
            return NSLocalizedString("KES 1,000 Annualy", comment: "Membership")
        case LifeMember:
            return NSLocalizedString("KES 5,000 Annualy One-off", comment: "Membership")
        }
    }
    
    static let count = 5
}

enum CorporatePlans: Int {
    case Guest = 0, Ordinary, Bronze, Silverline, GoldPremiere
    
    static func benefits(plan: CorporatePlans) -> [String] {
        switch plan {
        case Guest:
            return []
        case Ordinary:
            fallthrough
        case Bronze:
            fallthrough
        case Silverline:
            fallthrough
        case GoldPremiere:
            return [
                "Up to 5% discount for one year membership at EPlus",
                "Up to 15% discount at the Boma",
                "Invitations to attend special events, e.g., Life Members Day, KRC Gala, World Red Cross Day",
                "Message sent to them from KRCS with birthday wishes or with greetings towards what they celebrate.",
                "One member per quarter to be featured in the outreach.",
                "Up-to-date information on KRCS operations through e-mails such as KRC E-news",
                "Invitation to program launches",
                "Update on emergency precautions",
                "School clubs will receive free basic first aid training"]
        }
    }
    
    static func corporateIconImage(plan: CorporatePlans) -> UIImage? {
        switch plan {
        case Guest:
            return UIImage(named: "ic_guest")
        case Ordinary:
            return UIImage(named: "ic_corporate")
        case Bronze:
            return UIImage(named: "ic_bronze")
        case Silverline:
            return UIImage(named: "ic_guest")
        case GoldPremiere:
            return UIImage(named: "ic_gold")
        }
    }
    
    
    static func price(plan: CorporatePlans) -> Float? {
        switch plan {
        case Guest:
            return nil
        case Ordinary:
            return 100.0
        case Bronze:
            return 500.0
        case Silverline:
            return 1000.0
        case GoldPremiere:
            return 5000.0
        }
    }
    
    static func title(plan: CorporatePlans) -> String? {
        switch plan {
        case Guest:
            return NSLocalizedString("Continue as Guest", comment: "Membership")
        case Ordinary:
            return NSLocalizedString("Ordinary", comment: "Membership")
        case Bronze:
            return NSLocalizedString("Bronze", comment: "Membership")
        case Silverline:
            return NSLocalizedString("Silverline", comment: "Membership")
        case GoldPremiere:
            return NSLocalizedString("Gold Premiere", comment: "Membership")
        }
    }
    
    static func description(plan: CorporatePlans) -> String? {
        switch plan {
        case Guest:
            return NSLocalizedString("Free", comment: "Membership")
        case Ordinary:
            return NSLocalizedString("KES 50,000 Annualy", comment: "Membership")
        case Bronze:
            return NSLocalizedString("KES 100,000 Annualy", comment: "Membership")
        case Silverline:
            return NSLocalizedString("KES 250,000 Annualy", comment: "Membership")
        case GoldPremiere:
            return NSLocalizedString("KES 500,000 Annualy One-off", comment: "Membership")
        }
    }
    
    static let count = 5
}
    