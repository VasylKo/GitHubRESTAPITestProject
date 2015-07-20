//
//  NibView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

public class NibView: UIView {

    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadContentView()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        loadContentView()
    }
    
    
    public var nibName: String {
        return NSStringFromClass(self.dynamicType)
    }
    
    private func loadContentView() {
        let bundle = NSBundle(forClass: self.dynamicType)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        if let contentView = contentView {
            addSubview(contentView)
            contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
            let views: [NSObject : AnyObject] = [ "contentView": contentView ]
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        }
    }
    
    @IBOutlet private var contentView: UIView!

}
