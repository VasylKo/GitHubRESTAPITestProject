//
//  UserProfile.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

enum Gender: Int, CustomStringConvertible {
    case Unknown = 0
    case Male
    case Female
    case Other
    
    var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .Male:
            return "Male"
        case .Female:
            return "Female"
        case .Other:
            return "Other"
        }
    }
}

final class UserProfile: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var avatar: NSURL?
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var phone: String?
    var userDescription: String?
    var gender: Gender?
    var dateOfBirth: NSDate?
    var email: String?
    var backgroundImage: NSURL?
    var location: Location?
    var membershipDetails : MembershipDetails?
    var passportNumber: String?
    var postalAddress: Location?
    var profession: String?
    // countryBranch
    var permanentResidence: String?
    var educationLevel: String?
    
    var guest: Bool =  false
    var shops: [ObjectInfo]?
    
    var countFollowers: Int?
    var countFollowing: Int?
    var countPosts: Int?
    
    var defaultShopId: CRUDObjectId  {
        return shops?.first?.objectId ?? CRUDObjectInvalidId
    }
    
    var displayName: String {
        switch (firstName, lastName) {
        case (.None, .None):
            return NSLocalizedString("Unknown", comment: "Unnamed user display name")
        default:
            return String(format: "%@ %@", firstName ?? "", lastName ?? "")
        }
    }
    
    init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    convenience init() {
        self.init(objectId: CRUDObjectInvalidId)
    }
    
    init(objectId: CRUDObjectId) {
        self.objectId = objectId
    }
    
    func mapping(map: Map) {
        objectId <- (map["id"], CRUDObjectIdTransform())
        firstName <- map["firstName"]
        middleName <- map["middleName"]
        lastName <- map["lastName"]
        userDescription <- map["description"]
        phone <- map["phone"]
        email <- map["email"]
        avatar <- (map["avatar"], AmazonURLTransform())
        backgroundImage <- (map["background"], AmazonURLTransform())
        location <- map["location"]
        guest <- map["guest"]
        shops <- map["shops.data"]
        countFollowers <- map["followers.count"]
        countFollowing <- map["following.count"]
        countPosts <- map["posts.count"]
        membershipDetails <- map["membershipDetails"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/users"
    }
    
    static func myProfileEndpoint() -> String {
        return "/v1.0/me"
    }
    
    static func changePasswordEndpoint() -> String {
        return "/v1.0/users/changepassword"
    }
    
    static func verifyPhoneEndpoint() -> String {
        return "/v1.0/users/phoneVerification"
    }
    
    static func pushesEndpoint() -> String {
        return "/v1.0/users/registerPushNotifications"
    }
    
    static func userEndpoint(userId: CRUDObjectId) -> String {
        return (UserProfile.endpoint() as NSString).stringByAppendingPathComponent("\(userId)")
    }
    
    static func subscripttionEndpoint(userId: CRUDObjectId) -> String {
        return (UserProfile.userEndpoint(userId) as NSString).stringByAppendingPathComponent("subscription")
    }
    
    enum SubscriptionState: Int {
        case SameUser
        case Following
        case NotFollowing
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
 
    static let CurrentUserDidChangeNotification = "CurrentUserDidChangeNotification"
}