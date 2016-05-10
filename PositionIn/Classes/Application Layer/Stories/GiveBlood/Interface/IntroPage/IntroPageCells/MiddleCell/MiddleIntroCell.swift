//
//  TopIntroCell
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/6/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

//Implementation refer to article:
//https://blog.pivotal.io/labs/labs/expandable-uitableviewcells

import UIKit


class MiddleIntroCell: UITableViewCell, GiveBloodIntroCell {

    private let highPriority: UILayoutPriority = 999
    private let lowPriority: UILayoutPriority = 250
    weak var delegate: GiveBloodIntroCellDelegate?
    
    var showMore = false {
        didSet {
            detailContainerViewHeightConstraint?.priority = showMore ? lowPriority : highPriority
            buttonContainerViewHeightConstraint?.priority = showMore ? highPriority : lowPriority
            lastVisibleElementBottomAnchorConstraint?.constant = showMore ? 0 : 16
            detailsContainerView?.hidden = !showMore
            readMoreButton?.hidden = showMore
        }
    }
    
    @IBOutlet weak var detailsContainerView: UIView?
    @IBOutlet weak var cardContainerView: UIView?
    @IBOutlet weak var readMoreButton: UIButton?
    @IBOutlet weak var lastVisibleElementBottomAnchorConstraint: NSLayoutConstraint?
    @IBOutlet weak var detailContainerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailContainerViewHeightConstraint?.constant = 0
        buttonContainerViewHeightConstraint?.constant = 0
        cardContainerView?.layer.cornerRadius = 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func readMoreButtonPressed(sender: UIButton) {
        delegate?.readMoreButtonPressedOnCell(self)
    }
}
