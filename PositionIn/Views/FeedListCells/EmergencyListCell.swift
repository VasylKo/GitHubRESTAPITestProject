//
//  EmergencyListCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 09/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

import PosInCore

final class EmergencyListCell: TableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? CompactFeedTableCellModel
        assert(m != nil, "Invalid model passed")
        
        productImage.setImageFromURL(m!.imageURL, placeholder: UIImage(named: "PromotionDetailsPlaceholder"))
        headerLabel.text = m!.title
        detailsLabel.text = m!.details
        
        infoLabel.text =  nil
        if let coordinates = m!.location?.coordinates {
            locationController().distanceFromCoordinate(coordinates).onSuccess {
                [weak self] distance in
                let formatter = NSLengthFormatter()
                self?.infoLabel.text = formatter.stringFromMeters(distance)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.hnk_cancelSetImage()
    }
}
