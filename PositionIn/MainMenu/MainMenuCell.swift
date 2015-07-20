//
//  MainMenuCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class MainMenuCell: TableViewCell {
    
    @IBOutlet weak var selectionIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellImageTextModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        let image = UIImage(named: m!.image)
        iconImageView.image = image
        iconImageView.highlightedImage = image?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionIndicatorView.alpha = selected ? 1.0 : 0.0
        iconImageView.highlighted = selected
        let textStyle = selected ? UIFontTextStyleHeadline : UIFontTextStyleSubheadline
        titleLabel.font = UIFont.preferredFontForTextStyle(textStyle)
    }
}