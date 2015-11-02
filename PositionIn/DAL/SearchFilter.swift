//
//  SearchFilter.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import PosInCore
import CoreLocation
import CleanroomLogger
import BrightFutures

typealias SearchFilterUpdate = (SearchFilter) -> SearchFilter

struct SearchFilter: Mappable {
    typealias Money = Double
    static let minPrice: Money = 1
    static let maxPrice: Money = 10000
    static let defaultPrice: Money = 125
    static let CurrentFilterDidChangeNotification = "CurrentFilterDidChangeNotification"

    var startPrice: Money?
    var endPrice: Money?
    var startDate: NSDate?
    var endDate: NSDate?
    var categories: [ItemCategory]?
    var itemTypes: [FeedItem.ItemType]? 
    var name: String?
    var users: [CRUDObjectId]?
    var communities: [CRUDObjectId]?

    /**
    Sets filter location.
    
    - parameter location: location or nil for user location
    */
    static func setLocation(location: Location?) {
        var filter = SearchFilter.currentFilter
        filter.locationName = location?.name
        if let coordinates = location?.coordinates {
            filter.coordinates = coordinates
        } else {
            SearchFilter.updateCurrentLocation()
        }
        SearchFilter.currentFilter = filter
    }
    
    static var isCustomLocationSet: Bool {
        var filter = SearchFilter.currentFilter
        return filter.locationName != nil
    }
    
    private static var currentLocationToken = InvalidationToken()
    
    static func updateCurrentLocation() {
        currentLocationToken.invalidate()
        currentLocationToken = InvalidationToken()
        locationController().getCurrentCoordinate().onSuccess(token: currentLocationToken) { coordinate in
            var filter = SearchFilter.currentFilter
            filter.coordinates = coordinate
            SearchFilter.currentFilter = filter
        }
    }
    
    var locationName: String?
    
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
    

    var distance: Distance? {
        set {
            radius = newValue?.value()
        }
        get {
            return radius.flatMap { Distance(rawValue: $0) } ?? .Anywhere
        }
    }
    
    private var radius: Double?
    
    enum Distance: Double, CustomStringConvertible {
        case Km1 = 1
        case Km5 = 5
        case Km20 = 20
        case Km100 = 100
        case Anywhere = 0
        
        func value() -> Double? {
            switch self {
            case .Anywhere:
                return nil
            default:
                return Double(self.rawValue)
            }
        }
        
        func displayString() -> String {
            switch self {
            case .Anywhere:
                return NSLocalizedString("Anywhere", comment: "Update filter: Anywhere")
            default:
                let formatter = NSLengthFormatter()
                return formatter.stringFromValue(value() ?? 0, unit: locationController().lengthFormatUnit())
            }
        }
        
        var description: String {
            return "<Distance: \(displayString())"
        }
    }
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    init() {
        startPrice = SearchFilter.minPrice
        endPrice = SearchFilter.maxPrice
        itemTypes = [.Unknown]
        categories = ItemCategory.all()
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
        locationName <- map["locationName"]
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
            NSNotificationCenter.defaultCenter().postNotificationName(SearchFilter.CurrentFilterDidChangeNotification, object: nil)
        }
    }
    
    private static let kCurrentFilterKey = "kCurrentFilterKey"
}

extension SearchFilter: APIServiceQueryConvertible {
    var query: [String : AnyObject]  {
        var filter = self
        filter.locationName = nil
        filter.radius = filter.radius.map { locationController().localeUsesMetricSystem() ? $0 : $0 * 1.60934}
        var params = Mapper<SearchFilter>().toJSON(filter)
        return params
    }
}