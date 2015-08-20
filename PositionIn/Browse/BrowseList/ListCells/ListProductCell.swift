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


final class ListProductCell: TableViewCell {

    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellProductModel
        assert(m != nil, "Invalid model passed")

        if let url = NSURL(string: m!.imageURL) {
            productImage.hnk_setImageFromURL(url, placeholder: UIImage(named: "MainMenuForYou"))
        }
        headerLabel.text = m!.title
        detailsLabel.text = m!.owner
        infoLabel.text =  "\(m!.distance) miles"
        priceLabel.text = "$\(m!.price)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }

}
