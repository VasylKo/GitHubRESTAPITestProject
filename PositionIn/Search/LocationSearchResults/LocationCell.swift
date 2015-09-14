//
//  ProductActionCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CoreLocation

class LocationCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? LocationCellModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
    }

    @IBOutlet private weak var titleLabel: UILabel!

}

struct LocationCellModel: TableViewCellModel {
    var title: String? {
        return location.name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinates
    }
    
    let location: Location
    
    init(location: Location) {
        self.location = location
    }
}