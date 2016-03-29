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
        
        self.imageHeightConstaint.constant = CGFloat(m!.height)
        var frame = contentImage.frame
        frame.size.height = CGFloat(m!.height)
        contentImage.frame = frame
        self.updateConstraints()
        
        contentImage.setImageFromURL(m!.url, placeholder: UIImage(named: m!.placeholderString))
    }

    @IBOutlet weak var imageHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var contentImage: UIImageView!
}
