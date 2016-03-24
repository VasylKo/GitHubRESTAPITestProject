//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Product: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var text: String?
    var category: ItemCategory?
    var quantity: Int?
    var price: Float?
    var donations: Float?
    var deliveryMethod: DeliveryMethod? = .Unknown
    var photos: [PhotoInfo]?
    var location: Location?
    var imageURL: NSURL?
    var externalURLString: String?
    var startDate: NSDate?
    var endData: NSDate?
    var links : [NSURL]?
    var attachments : [Attachment]?
    var author: UserInfo?
    var numOfBeneficiaries: Int?
    var distanceString: String?
    var date: NSDate?
    var type: FeedItem.ItemType?
    
    
/*
    //TODO:
    "itemCategory": <guid>
*/
    

/* Details
    "itemCategory": {
    "id": <guid>,
    "name": <string>
    },
    "author": <guid?>,
    "community": <guid?>,
*/

    
    enum DeliveryMethod: Int {
        case Unknown
        case Pickup, Deliver, PickupOrDeliver
    }
    
    
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
        category <- (map["category"], EnumTransform())
        quantity <- map["quantity"]
        price <- map["price"]
        donations <- map["donations"]
        deliveryMethod <- (map["deliveryMethod"], EnumTransform())
        photos <- map["photos"]
        location <- map["location"]
        imageURL <- (map["image"], ImageURLTransform())
        startDate <- (map["startDate"], APIDateTransform()) 
        endData <- (map["endDate"], APIDateTransform())
        externalURLString <- map["externalUrl"]
        links <- (map["links"], URLTransform())
        attachments <- map["attachments"]
        author <- map["author"]
        numOfBeneficiaries <- map["numOfBeneficiaries"]
        distanceString <- map["distanceString"]
        date <- (map["date"], APIDateTransform())
        type <- (map["type"], EnumTransform())
    }
    
    static func endpoint() -> String {
        return Shop.endpoint()
    }
    
    static func shopItemsEndpoint(shopId: CRUDObjectId, productId: CRUDObjectId) -> String {
        return (Product.shopItemsEndpoint(shopId) as NSString).stringByAppendingPathComponent("\(productId)")
    }
    
    static func shopItemsEndpoint(shopId: CRUDObjectId) -> String {
        return (Product.endpoint() as NSString).stringByAppendingPathComponent("\(shopId)/items")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}