//
//  PostEventCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/20/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import UIKit

final class PostListCell: TableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
        productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "compactPlaceholder"))
        titleLabel.text = m!.title
        infoLabel.text = m!.details

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
}