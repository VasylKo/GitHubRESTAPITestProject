//
//  PostEventCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/20/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import Haneke
import UIKit

final class PostListCell: TableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellPostModel
        assert(m != nil, "Invalid model passed")
        
        if let url = NSURL(string: m!.imageURL) {
            productImage.hnk_setImageFromURL(url, placeholder: UIImage(named: "MainMenuForYou"))
        }
        
        infoLabel.text = m!.info
        titleLabel.text = m!.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
}