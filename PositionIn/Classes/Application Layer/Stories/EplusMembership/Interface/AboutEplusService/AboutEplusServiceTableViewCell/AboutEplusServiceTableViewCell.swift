//
//  AboutEplusServiceTableViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class AboutEplusServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var subTitle: UILabel?
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView?
    @IBOutlet weak var cellContainerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func configureCellWith(title: String?, subTitle: String?, image: UIImage?) {
        activityIndicatior?.hidden = true
        cellContainerView?.hidden = false
        
        icon?.image = image
        self.title?.text = title
        self.subTitle?.text = subTitle
        accessoryType = .DisclosureIndicator
    }
}
