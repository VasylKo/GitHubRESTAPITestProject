//
//  TopIntroCell
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/6/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit


class TopIntroCell: UITableViewCell, GiveBloodIntroCell {

    private let highPriority: UILayoutPriority = 999
    private let lowPriority: UILayoutPriority = 250
    weak var delegate: GiveBloodIntroCellDelegate?
    
    var showMore = false {
        didSet {
            detailContainerViewHeightConstraint?.priority = showMore ? lowPriority : highPriority
            buttonContainerViewHeightConstraint?.priority = showMore ? highPriority : lowPriority
            readMoreButton?.hidden = showMore
        }
    }
    
    @IBOutlet weak var readMoreButton: UIButton?
    @IBOutlet weak var detailContainerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var buttonContainerViewHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailContainerViewHeightConstraint?.constant = 0
        buttonContainerViewHeightConstraint?.constant = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func readMoreButtonPressed(sender: UIButton) {
        delegate?.readMoreButtonPressedOnCell(self)
    }
}
