//
//  SearchEntityCell.swift
//  PositionIn
//
//  Created by mpol on 10/5/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class SearchEntityCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? SearchItemCellModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        
        if let localImageName = m!.localImageName {
            entityImageView.setImageFromURL(m!.remoteImageURL, placeholder: UIImage(named: localImageName))
        }
        
        if let searchString = m!.searchString {
            let range: NSRange = (m!.title!.lowercaseString as NSString).rangeOfString(searchString)
            if (range.length > 0) {
                var attrString = NSMutableAttributedString(string: m!.title!)
                let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(15)]
                var range: NSRange = (m!.title!.lowercaseString as NSString).rangeOfString(searchString)
                
                attrString.addAttributes(attributes, range: range)
                titleLabel?.attributedText = attrString
            }
        }
        
        self.entityImageView.clipsToBounds = true
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.entityImageView.layer.cornerRadius = self.entityImageView.frame.size.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        entityImageView.hnk_cancelSetImage()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var entityImageView: UIImageView!
    
}
