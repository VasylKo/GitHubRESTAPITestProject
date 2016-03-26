//
//  Notification.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//


import ObjectMapper
import CleanroomLogger

struct SystemNotification : CRUDObject {

    enum Type: Int {
        case Unknown = 0
        case AmbulanceOnTheWay
        case AmbulanceCancelled
        case MPESAPaymentCompleted
        case MPESAPaymentFailed
        case MembershipIsAboutToExpired
        case MembershipExpired
        case OrderDelivered
    }
    
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var title: String?
    var message: String?
    var isRead: Bool?
    var createdDate: NSDate?
    var type : Type = .Unknown
    
    //MARK: Mappable
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        objectId <-  map["notificationId"]
        title <- map["title"]
        message <- map["message"]
        createdDate <-  (map["createdDate"], APIDateTransform())
        isRead <- map["isRead"]
        type <- map["type"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/notifications"
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}