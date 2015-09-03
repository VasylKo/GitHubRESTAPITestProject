//
//  DescriptionTableViewCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

final class DescriptionTableViewCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellTextModel
        assert(m != nil, "Invalid model passed")
        descriptionLabel.text = m!.title
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel!
}