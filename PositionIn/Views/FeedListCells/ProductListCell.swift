//
//  ListProductCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 22/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class ProductListCell: TableViewCell {

    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")

        productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "hardware_img_default"))
        headerLabel.text = m!.title
        detailsLabel.text = m!.details
        infoLabel.text =  m!.info
        if let price = m!.price {
            infoLabel.text = "\(Int(price)) beneficiaries"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
}
