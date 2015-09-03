//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct ShopItemProduct: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var author: CRUDObjectId?
    var name: String?
    var descriptionProd: String?
    var category: Int = 1
    var price: Int? 
    var quantity: Int = 1
    var deliveryMethod: Int = 1

    var photos: [PhotoInfo]?

    
    var location: Location?
    
    
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
        author <- (map["author"], CRUDObjectIdTransform())
        name <- map["name"]
        descriptionProd <- map["description"]
        photos <- map["photos"]
        location <- map["location"]
        category <- map["category"]
        deliveryMethod <- map["deliveryMethod"]
        price <- map["price"]
        quantity <- map["quantity"]
    }
    
    static func endpoint() -> String {
        return "/v1.0/shops/items"
    }
    
    static func endpoint(productId: CRUDObjectId, shopId: CRUDObjectId) -> String {
        return "/v1.0/shops/\(shopId)/items/\(productId)"
        return "/v1.0/shops/items/\(productId)"
    }
    
    static func userProductsEndpoint(shopId: CRUDObjectId) -> String {
        return "/v1.0/shops/\(shopId)/items"
        return "v1.0/shops/items"
    }
    
    static func communityProductsEndpoint(community: Community) -> String {
        //TODO: fix this
//         if let shop = community.shops?.first, let shopId = shop["id"]  {
//            Community.endpoint().stringByAppendingPathComponent("\(community.objectId)/shops/\(shopId)/items")
//        }
        
        return Community.endpoint().stringByAppendingPathComponent("\(community.objectId)/shops/items")
    }
    
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}