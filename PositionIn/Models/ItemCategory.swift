//
//  ItemCategory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import UIKit

enum ItemCategory: Int, DebugPrintable {
    case Unknown
    case AnimalsPetSupplies, ApparelAccessories, ArtsEntertainment, BabyToddler, BusinessIndustrial,
         CamerasOptics, Electronics, Food, Furniture, Hardware, HealthBeauty, HomeGarden, LuggageBags
    
    static func all() -> [ItemCategory] {
        return [
            .AnimalsPetSupplies, .ApparelAccessories, .ArtsEntertainment, .BabyToddler, .BusinessIndustrial,
            .CamerasOptics, .Electronics, .Food, .Furniture, .Hardware, .HealthBeauty, .HomeGarden, .LuggageBags
        ]
    }
    
    func displayString() -> String {
        switch self {
        case .AnimalsPetSupplies:
            return NSLocalizedString("Blood", comment: "ItemCategory: AnimalsPetSupplies")
        case .ApparelAccessories:
            return NSLocalizedString("Construction", comment: "ItemCategory: ApparelAccessories")
        case .ArtsEntertainment:
            return NSLocalizedString("Clothes", comment: "ItemCategory: ArtsEntertainment")
        case .BabyToddler:
            return NSLocalizedString("Electronics", comment: "ItemCategory: BabyToddler")
        case .BusinessIndustrial:
            return NSLocalizedString("Fire", comment: "ItemCategory: BusinessIndustrial")
        case .CamerasOptics:
            return NSLocalizedString("Food", comment: "ItemCategory: CamerasOptics")
        case .Electronics:
            return NSLocalizedString("Hardware", comment: "ItemCategory: Electronics")
        case .Food:
            return NSLocalizedString("Healthcare", comment: "ItemCategory: Food")
        case .Furniture:
            return NSLocalizedString("Medicine", comment: "ItemCategory: Furniture")
        case .Hardware:
            return NSLocalizedString("Manpower", comment: "ItemCategory: Hardware")
        case .HealthBeauty:
            return NSLocalizedString("Religious & Ceremonial", comment: "ItemCategory: HealthBeauty")
        case .HomeGarden:
            return NSLocalizedString("Vehicles & Parts", comment: "ItemCategory: HomeGarden")
        case .LuggageBags:
            return NSLocalizedString("Water", comment: "ItemCategory: LuggageBags")
        case .Unknown:
            fallthrough
        default:
            return NSLocalizedString("All", comment: "ItemCategory: Unknown")
        }
    }
    
    func displayImage() -> UIImage? {
        let image: UIImage?
        switch self {
        case .ApparelAccessories:
            image =  UIImage(named: "category_blood_map")
        case .ArtsEntertainment:
            image =  UIImage(named: "construction_map")
        case .BabyToddler:
            image =  UIImage(named: "ProductMarker")
        case .BusinessIndustrial:
            image =  UIImage(named: "category_electronics_map")
        case .CamerasOptics:
            image =  UIImage(named: "ProductMarker")
        case .Electronics:
            image =  UIImage(named: "category_food_map")
        case .Food:
            image =  UIImage(named: "category_hardware_map")
        case .Furniture:
            image =  UIImage(named: "category_health_beauty_map")
        case .Hardware:
            image =  UIImage(named: "ProductMarker")
        case .HealthBeauty:
            image =  UIImage(named: "ProductMarker")
        case .HomeGarden:
            image =  UIImage(named: "category_religious_ceremonial_map")
        case .LuggageBags:
            image =  UIImage(named: "category_vehicles_parts_map")
        default:
            image =  UIImage(named: "category_water_map")
        }
        return image
    }
    
    var debugDescription: String {
        return "<ItemCategory:\(displayString())>"
    }
}