//
//  CollectionResponse.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger
import PosInCore

struct QuickSearchResponse: Mappable {
    private(set) var categories: [ItemCategory]!
    private(set) var products: [ObjectInfo]!
    private(set) var promotions: [ObjectInfo]!
    private(set) var communities: [UserInfo]!
    private(set) var events: [ObjectInfo]!
    private(set) var peoples: [UserInfo]!
    
    init?(_ map: Map) {
        mapping(map)
        switch (categories, products, promotions, communities, events, peoples) {
        case (.Some, .Some, .Some, .Some, .Some, .Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        products <- map["items"] //TODO: need check
        promotions <- map["promotions"]
        communities <- map["communities"]
        events <- map["events"]
        categories <- (map["categories"], ListTransform(itemTransform:EnumTransform()))
        peoples <- map["peoples"]
        
        Log.verbose?.value(promotions)
        Log.verbose?.value(communities)
        Log.verbose?.value(events)
        Log.verbose?.value(peoples)
        Log.verbose?.value(categories)
        Log.verbose?.value(peoples)
    }
    
    var description: String {
        return "<\(self.dynamicType)-(\(peoples)):\(promotions):\(communities):\(events)c:\(peoples)>"
    }
}

struct CollectionResponse<C: CRUDObject>: Mappable {
    private(set) var items: [C]!
    private(set) var total: Int!
    
    init?(_ map: Map) {
        mapping(map)
        switch (items, total) {
        case (.Some, .Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        items <- map["data"]
        total <- map["count"]
    }

    var description: String {
        return "<\(self.dynamicType)-(\(total)):\(items)>"
    }
}

struct UpdateResponse: Mappable{
    private(set) var objectId: CRUDObjectId = CRUDObjectInvalidId
    
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
    }
    
    var description: String {
        return "<\(self.dynamicType)-(\(objectId))>"
    }
}


// Session response
struct AuthResponse: Mappable, DebugPrintable {
    typealias Token = String!
    private(set) var accessToken: Token
    private(set) var refreshToken: Token
    private(set) var expires: Int!
    
    init?(_ map: Map) {
        mapping(map)
        switch (accessToken,refreshToken,expires) {
        case (.Some, .Some, .Some):
            break
        default:
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    private init(accessToken: Token, refreshToken: Token, expires: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expires = expires
    }
    
    mutating func mapping(map: Map) {
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
        expires <- map["expires_in"]
    }
    
    var debugDescription: String {
        return "Access:\(accessToken), Refresh: \(refreshToken), Expires: \(expires)"
    }
    
    static func invalidAuth() -> AuthResponse {
        return  AuthResponse(accessToken: "",refreshToken: "",expires: -1)
    }
}
