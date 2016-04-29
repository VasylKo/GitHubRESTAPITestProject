//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Promotion: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var text: String?
    var endDate: NSDate?
    var startDate: NSDate?
    var discount: Float?
    var photos: [PhotoInfo]?
    var location: Location?
    var shop: CRUDObjectId?
    var author: CRUDObjectId?
//


    /*
    TODO:

    "community": <guid?>,
    "items": [<guid>],
    */
    
    /*
    Details:
    
    "items": [{
    "data":{
    "id": <guid>,
    "name": <string>,
    "photos": [{
				"id": <guid>,
				"url": <string>
				}]
    },
    "count": <number>
    }]
    "author": <guid?>,

    
    */
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
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
    
    mutating func mapping(map: Map) {
        
        objectId <- (map["id"], CRUDObjectIdTransform())
        name <- map["name"]
        text <- map["description"]
        endDate <- (map["endDate"], APIDateTransform())
        startDate <- (map["startDate"], APIDateTransform())
        discount <- map["discount"]
        photos <- map["photos"]
        location <- map["location"]
        shop <- (map["shop"], CRUDObjectIdTransform())
        author <- (map["author"], CRUDObjectIdTransform())
    }
    
    static func endpoint() -> String {
        return "/v1.0/promotions"
    }
    
    static func endpoint(promotionId: CRUDObjectId) -> String {
        return (Promotion.endpoint() as NSString).stringByAppendingPathComponent("\(promotionId)")
    }
    
    static func userPromotionsEndpoint(userId: CRUDObjectId) -> String {
        return (UserProfile.userEndpoint(userId) as NSString).stringByAppendingPathComponent("promotions")
    }
    
    static func communityPromotionsEndpoint(communityId: CRUDObjectId) -> String {
        return (Community.endpoint() as NSString).stringByAppendingPathComponent("\(communityId)/promotions")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}