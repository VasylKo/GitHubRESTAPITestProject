//
//  ProductActionCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class PostImageCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellURLModel
        assert(m != nil, "Invalid model passed")
        contentImage.setImageFromURL(m!.url, placeholder: UIImage(named: "communityPlaceholder"))
    }

    @IBOutlet weak var contentImage: UIImageView!
}