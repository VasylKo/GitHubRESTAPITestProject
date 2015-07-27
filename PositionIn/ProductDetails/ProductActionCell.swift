//
//  ProductActionCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class ProductActionCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellImageTextModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        iconImageView.image = UIImage(named: m!.image)?.imageWithRenderingMode(.AlwaysTemplate)
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
}
