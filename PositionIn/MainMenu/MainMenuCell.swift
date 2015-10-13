//
//  MainMenuCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class MainMenuCell: TableViewCell {
    
    @IBOutlet private weak var selectionIndicatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellImageTextModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        let image = UIImage(named: m!.image)
        iconImageView.image = image
        iconImageView.tintColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46)
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