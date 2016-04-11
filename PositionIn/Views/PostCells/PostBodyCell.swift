//
//  ProductActionCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class PostBodyCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellTextModel
        assert(m != nil, "Invalid model passed")
        contentLabel.text = m!.title
        leftMarginConstaint.constant = CGFloat(m!.leftMargin)
        selectionStyle = .None
    }

    @IBOutlet weak var leftMarginConstaint: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
}
