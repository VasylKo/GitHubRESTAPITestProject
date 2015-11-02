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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installContentLayoutGuide()
    }
    
    /// Position of this header/footer in the table view
    internal(set) public var position: Position = .Undefined {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /**
    You should add subviews to this view, and pin those views to it using Auto Layout constraints.
    
    This view is inset by contentLayoutGuideInsets + _systemContentLayoutGuideInsets. contentLayoutGuideInsets can be overridden by subclasses.
    */
    private(set) public var contentLayoutGuideView: UIView! = nil
    private var contentLayoutGuideWidthConstraint: NSLayoutConstraint! = nil
    private var contentLayoutGuideConstraints: [NSLayoutConstraint] = []
    
    private func installContentLayoutGuide(){
        contentLayoutGuideView = UIView()
        contentLayoutGuideView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentLayoutGuideView)
        // For some reason, doing |-left-[_contentLayoutGuideView]-(right@999)-| doesn't work when the header's label is more than one line long, so we have to do this as a width.
        contentLayoutGuideWidthConstraint = NSLayoutConstraint(item: contentLayoutGuideView, attribute: .Width, relatedBy: .Equal,
                                                               toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0)
        // Allow the width constraint to be broken by subviews that are constrained with additional non-zero padding
        contentLayoutGuideWidthConstraint.priority = /*UILayoutPriorityRequired*/ 1000 - 1
        contentView.addConstraint(contentLayoutGuideWidthConstraint)        
    }
    
    public var contentLayoutGuideInsets: UIEdgeInsets {
        let (top, bottom): (CGFloat, CGFloat) = {
            switch self.position {
            case .Header, .FirstHeader:
                return (self.kLargeVerticalPadding, self.kSmallVerticalPadding)
            case .Footer, .LastFooter:
                return (self.kSmallVerticalPadding, self.kLargeVerticalPadding)
            default:
                fatalError("undefined position")
            }
        }()
        return UIEdgeInsets(top: top, left: kDefaultHorizontalPadding, bottom: bottom, right: kDefaultHorizontalPadding)
    }
    
    public override func layoutSubviews() {
        let edgeInsets = totalInsents()
        contentLayoutGuideWidthConstraint.constant = max(bounds.width - edgeInsets.left - edgeInsets.right, 0)
        super.layoutSubviews()
    }
    
    public override func updateConstraints() {

        contentView.removeConstraints(contentLayoutGuideConstraints)

        let vfl: String = {
            switch self.position {
            case .Header, .FirstHeader:
                return "V:|-(>=top@priorityNotRequired)-[contentLayoutGuideView]-bottom-|"
            case .Footer, .LastFooter:
                return "V:|-top-[contentLayoutGuideView]-(>=bottom@priorityNotRequired)-|"
            default:
                fatalError("undefined position")
            }
        }()
        let metrics: [NSObject: AnyObject] = {
           let edgeInsets = self.totalInsents()
            return [
                "left": edgeInsets.left,
                "right": edgeInsets.right,
                "top": edgeInsets.top,
                "bottom": edgeInsets.bottom,
                "priorityNotRequired": (/*UILayoutPriorityRequired*/1000 - 1)
            ]
        }()
        let views: [NSObject: AnyObject] = [ "contentLayoutGuideView" : contentLayoutGuideView ]

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(vfl, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views) as! [NSLayoutConstraint]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[_contentLayoutGuideView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views) as! [NSLayoutConstraint]

        contentView.addConstraints(verticalConstraints + horizontalConstraints)
        super.updateConstraints()
    }
    
    private func totalInsents() -> UIEdgeInsets {
        // When you don't specify section footers, they are 17.5pt tall by default. This makes up the
        // inter-section padding in grouped table views. Since the first section header doesn't have a
        // (previous section's) footer before it, the first section header's height is made
        // 17.5pts taller by the system when tableView:heightForHeaderInSection: isn't implemented.
        // This code emulates the system behavior. A similar thing happens for footers.
        let extraTopPadding = (position == .FirstHeader) ? kFirstLastSectionExtraVerticalPadding : 0
        let extraBottomPadding = (position == .LastFooter) ? kFirstLastSectionExtraVerticalPadding : 0
        var edgeInsets = contentLayoutGuideInsets
        edgeInsets.top += extraTopPadding
        edgeInsets.bottom += extraBottomPadding
        return edgeInsets
    }
    
    public enum Position {
        case Undefined
        case Header // Any header but the first one in the table view
        case FirstHeader // The first header in the table view
        case Footer // Any footer but the last on one in the table view
        case LastFooter // The last footer in the table view
    }
    
    private let kSmallVerticalPadding: CGFloat = 7;
    private let kLargeVerticalPadding: CGFloat = 12;
    private let kDefaultHorizontalPadding: CGFloat = 15;
    private let kFirstLastSectionExtraVerticalPadding: CGFloat = 17.5;

}