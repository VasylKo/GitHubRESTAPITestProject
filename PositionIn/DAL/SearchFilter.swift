//
//  SearchFilter.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper
import PosInCore
import CoreLocation

struct SearchFilter: Mappable {

    var startPrice: Double?
    var endPrice: Double?
    var startDate: NSDate?
    var endDate: NSDate?
    var radius: Double? = 5
    var categories: [ItemCategory]?
    var itemTypes: [FeedItem.ItemType]? = [.Unknown]
    var name: String?
    var users: [CRUDObjectId]?
    var communities: [CRUDObjectId]?

    
    var coordinates: CLLocationCoordinate2D? {
        set {
            lat = newValue?.latitude
            lon = newValue?.longitude
        }
        get {
            if let lat = self.lat,
               let lon = self.lon {
                let coord = CLLocationCoordinate2DMake(lat, lon)
                if CLLocationCoordinate2DIsValid(coord) == true {
                    return coord
                }
            }
            return nil
        }
    }
    
    private var lat: CLLocationDegrees?
    private var lon: CLLocationDegrees?
    
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    init() {
        startPrice = 1
        endPrice = 1000
        radius = 5
        itemTypes = [.Unknown]
    }
    
    mutating func mapping(map: Map) {
        
        startPrice <- map["price.from"]
        endPrice <- map["price.to"]
        startDate <- (map["time.from"], APIDateTransform())
        endDate <- (map["time.to"], APIDateTransform())
        radius <- map["radius"]
        name <- map["name"]
        
        itemTypes <- (map["type"], ListTransform(itemTransform: EnumTransform()))
        categories <- (map["categories"], ListTransform(itemTransform: EnumTransform()))
        users <- (map["users"], ListTransform(itemTransform: CRUDObjectIdTransform()))
        communities <- (map["communities"], ListTransform(itemTransform: CRUDObjectIdTransform()))
        lat <- map["lat"]
        lon <- map["lon"]
        
    }
    
    static var currentFilter: SearchFilter {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if  let json = defaults.objectForKey(kCurrentFilterKey) as? [String: AnyObject],
                let filter = Mapper<SearchFilter>().map(json) {
                return filter
            }
            return SearchFilter()
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            let json = Mapper<SearchFilter>().toJSON(newValue)
            defaults.setObject(json, forKey: kCurrentFilterKey)
        }
    }
    
    private static let kCurrentFilterKey = "kCurrentFilterKey"
}

extension SearchFilter: APIServiceQueryConvertible {
    var query: [String : AnyObject]  {
        return Mapper<SearchFilter>().toJSON(self)
    }
}