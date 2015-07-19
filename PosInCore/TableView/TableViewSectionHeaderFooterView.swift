//
//  TableViewSectionHeaderFooterView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

public class TableViewSectionHeaderFooterView: UITableViewHeaderFooterView {
    
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        installContentLayoutGuide()
    }
    
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installContentLayoutGuide()
    }
    
    /// Position of this header/footer in the table view
    internal(set) public var position: Position = .Undefined
    
    /**
    You should add subviews to this view, and pin those views to it using Auto Layout constraints.
    
    This view is inset by contentLayoutGuideInsets + _systemContentLayoutGuideInsets. contentLayoutGuideInsets can be overridden by subclasses.
    */
    private(set) public var contentLayoutGuideView: UIView! = nil
    private var contentLayoutGuideWidthConstraint: NSLayoutConstraint! = nil
    
    private func installContentLayoutGuide(){
        contentLayoutGuideView = UIView()
        contentLayoutGuideView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(contentLayoutGuideView)
        // For some reason, doing |-left-[_contentLayoutGuideView]-(right@999)-| doesn't work when the header's label is more than one line long, so we have to do this as a width.
        contentLayoutGuideWidthConstraint = NSLayoutConstraint(item: contentLayoutGuideView, attribute: .Width, relatedBy: .Equal,
                                                               toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0)
        // Allow the width constraint to be broken by subviews that are constrained with additional non-zero padding
        contentLayoutGuideWidthConstraint.priority = /*UILayoutPriorityRequired*/ 1000 - 1
        contentView.addConstraint(contentLayoutGuideWidthConstraint)        
    }
    
    public enum Position {
        case Undefined
        case Header // Any header but the first one in the table view
        case FirstHeader // The first header in the table view
        case Footer // Any footer but the last on one in the table view
        case LastFooter // The last footer in the table view
    }
}