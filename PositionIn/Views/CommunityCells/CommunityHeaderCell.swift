//
//  CommunityInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class CommunityHeaderCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellURLTextModel
        assert(m != nil, "Invalid model passed")
        captionLabel.text = m!.title
        contentImageView.setImageFromURL(m!.url, placeholder: UIImage(named: ""))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.hnk_cancelSetImage()
    }

    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
}
