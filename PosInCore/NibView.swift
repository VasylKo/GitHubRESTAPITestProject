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
    
    required public init?(coder aDecoder: NSCoder) {
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
            addSubViewOnEntireSize(contentView)
        }
    }
    
    @IBOutlet private var contentView: UIView!

}
