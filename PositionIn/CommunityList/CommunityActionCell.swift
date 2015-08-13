//
//  CommunityInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class CommunityActionCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellInvalidModel
        assert(m != nil, "Invalid model passed")
    }
    
    
}
