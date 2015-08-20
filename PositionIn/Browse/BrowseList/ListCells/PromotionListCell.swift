//
//  PromotionListCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 8/20/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import Haneke
import UIKit

final class PromotionListCell: TableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellPromotionModel
        assert(m != nil, "Invalid model passed")
        
        if let url = NSURL(string: m!.imageURL) {
            productImage.hnk_setImageFromURL(url, placeholder: UIImage(named: "MainMenuForYou"))
        }
        
        authorLabel.text = m!.author
        titleLabel.text = m!.title
        discountLabel.text = m!.discount
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
    
}