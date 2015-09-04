//
//  ListProductCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 22/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import Haneke


final class ProductListCell: TableViewCell {

    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? ComapctBadgeFeedTableCellModel
        assert(m != nil, "Invalid model passed")

        if let url = m!.imageURL {
            productImage.hnk_setImageFromURL(url, placeholder: UIImage(named: "MainMenuForYou"))
        }
        headerLabel.text = m!.title
        detailsLabel.text = m!.details
        infoLabel.text =  m!.info
        priceLabel.text = m!.badge
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }

}
