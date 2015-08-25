//
//  ItemCategory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

enum ItemCategory: Int, DebugPrintable {
    case Unknown
    case AnimalsPetSupplies, ApparelAccessories, ArtsEntertainment, BabyToddler, BusinessIndustrial,
         CamerasOptics, Electronics, Food, Furniture, Hardware, HealthBeauty, HomeGarden, LuggageBags,
         Media, OfficeSupplies, ReligiousCeremonial, Software, SportingGoods, ToysGames, VehiclesParts
    
    func string() -> String {
        switch self {
        case .Unknown:
            fallthrough
        case .AnimalsPetSupplies:
            return NSLocalizedString("Animals & Pet Supplies", comment: "ItemCategory: AnimalsPetSupplies")
        case .ApparelAccessories:
            return NSLocalizedString("Apparel & Accessories", comment: "ItemCategory: ApparelAccessories")
        case .ArtsEntertainment:
            return NSLocalizedString("Arts & Entertainment", comment: "ItemCategory: ArtsEntertainment")
        case .BabyToddler:
            return NSLocalizedString("Baby & Toddler", comment: "ItemCategory: BabyToddler")
        case .BusinessIndustrial:
            return NSLocalizedString("Business & Industrial", comment: "ItemCategory: BusinessIndustrial")
        case .CamerasOptics:
            return NSLocalizedString("Cameras & Optics", comment: "ItemCategory: CamerasOptics")
        case .Electronics:
            return NSLocalizedString("Electronics", comment: "ItemCategory: Electronics")
        case .Food:
            return NSLocalizedString("Food", comment: "ItemCategory: Food")
        case .Furniture:
            return NSLocalizedString("Furniture", comment: "ItemCategory: Furniture")
        case .Hardware:
            return NSLocalizedString("Hardware", comment: "ItemCategory: Hardware")
        case .HealthBeauty:
            return NSLocalizedString("Health & Beauty", comment: "ItemCategory: HealthBeauty")
        case .HomeGarden:
            return NSLocalizedString("Home & Garden", comment: "ItemCategory: HomeGarden")
        case .LuggageBags:
            return NSLocalizedString("Luggage & Bags", comment: "ItemCategory: LuggageBags")
        case .Media:
            return NSLocalizedString("Media", comment: "ItemCategory: Media")
        case .OfficeSupplies:
            return NSLocalizedString("Office Supplies", comment: "ItemCategory: OfficeSupplies")
        case .ReligiousCeremonial:
            return NSLocalizedString("Religious & Ceremonial", comment: "ItemCategory: ReligiousCeremonial")
        case .Software:
            return NSLocalizedString("Software", comment: "ItemCategory: Software")
        case .SportingGoods:
            return NSLocalizedString("Sporting Goods", comment: "ItemCategory: SportingGoods")
        case .ToysGames:
            return NSLocalizedString("Toys & Games", comment: "ItemCategory: ToysGames")
        case .VehiclesParts:
            return NSLocalizedString("Vehicles & Parts", comment: "ItemCategory: VehiclesParts")
        default:
            return NSLocalizedString("Unknown", comment: "ItemCategory: Unknown")
        }
    }
    
    var debugDescription: String {
        return "<ItemCategory:\(string())>"
    }
}