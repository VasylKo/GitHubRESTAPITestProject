//
//  MainMenuCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class MainMenuBadgeCell: TableViewCell {
    
    @IBOutlet private weak var selectionIndicatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!    
    @IBOutlet private weak var badgeView: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellWithBadgetModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        let image = UIImage(named: m!.image)
        iconImageView.image = image
        iconImageView.highlightedImage = image?.imageWithRenderingMode(.AlwaysTemplate)
        if let badgeText = m!.badge {
            badgeView.text = badgeText
            badgeView.hidden = false
        } else {
            badgeView.hidden = true
        }
        badgeView.backgroundColor = UIScheme.mainThemeColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionIndicatorView.alpha = selected ? 1.0 : 0.0
        iconImageView.highlighted = selected
        let textStyle = selected ? UIFontTextStyleHeadline : UIFontTextStyleSubheadline
        titleLabel.font = UIFont.preferredFontForTextStyle(textStyle)
    }
}

public struct TableViewCellWithBadgetModel: TableViewCellModel {
    public let title: String
    public let image: String
    public let badge: String?
    
    public init(title: String, imageName: String, badge: String? = nil) {
        self.title = title
        self.badge = badge
        image = imageName
    }
}
