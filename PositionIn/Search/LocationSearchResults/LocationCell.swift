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
    let title: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}