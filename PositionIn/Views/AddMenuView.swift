//
//  AddMenuView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

@objc protocol AddMenuViewDelegate {
    optional func addMenuView(addMenuView: AddMenuView, willExpand expanded:Bool)
    optional func addMenuView(addMenuView: AddMenuView, didExpand expanded:Bool)
}

final class AddMenuView: UIView {
    typealias ItemAction = () -> Void

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    dynamic var expanded: Bool {
        get {
            return mExpanded
        }
        set {
            setExpanded(newValue)
        }
    }
    
    @IBAction func toogleMenuTapped(sender: AnyObject) {
        expanded = !expanded
    }
    
    func setExpanded(expanded: Bool, animated:Bool = true) {
        delegate?.addMenuView?(self, willExpand: expanded)
        let duration: NSTimeInterval = animated ? self.animationDuration : 0.0
        if expanded {
            applyExpandAnimation(duration)
        } else {
            applyCollapseAnimation(duration)
        }
        bringSubviewToFront(startButton)
        decorationLayer.zPosition = startButton.layer.zPosition - 1
    }

    func update(transitionContext: UIViewControllerTransitionCoordinatorContext!) {
        setNeedsLayout()
        setExpanded(false, animated: false)
    }
    
    weak var delegate: AddMenuViewDelegate?
    var direction: AnimationDirection = .TopRight
    
    func setItems(items: [MenuItem]) {
        for itemView in menuItemViews {
            itemView.removeFromSuperview()
        }
        
        menuItemViews = items.map() { menuItem in
            let menuItemView = AddMenuItemView(direction: self.direction, menuItem: menuItem)
            menuItemView.sizeToFit()
            menuItemView.setNeedsLayout()
            
            menuItemView.frame = CGRect(origin: CGPointZero, size: menuItemView.bounds.size)
            self.addSubview(menuItemView)
            return menuItemView
        }        
        setExpanded(false, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startButton.frame = bounds
        for item in menuItemViews {
            item.frame = self.bounds
        }
    }

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        let decorationRect = bounds.insetBy(dx: -decorationInset, dy: -decorationInset)
        decorationLayer.frame = bounds
        decorationLayer.path = UIBezierPath(ovalInRect: decorationRect).CGPath
    }
    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if (mExpanded) {
            let rect = menuItemViews.reduce(bounds) { return CGRectUnion($0, $1.frame) }
            return rect.contains(point)
        }
        return super.pointInside(point, withEvent: event)
    }

    
    private var menuItemViews: [AddMenuItemView] = []
    private let startButton = RoundButton(image: UIImage(named: "AddIcon")!)
    private var mExpanded: Bool  = true
    private let itemsPadding: CGFloat = 10
    private let decorationInset: CGFloat = 5.0
    private let animationDuration: NSTimeInterval = 0.4
    private let decorationLayer = CAShapeLayer()
}

//MARK: Types
extension AddMenuView {
    
    enum AnimationDirection {
        case TopRight
    }
    
    struct MenuItem {
        let title: String
        let icon: UIImage
        let color: UIColor
        let action: ItemAction?
        
        static func productItemWithAction(action: ItemAction?) -> MenuItem {
            return MenuItem(
                title: NSLocalizedString("PRODUCT",comment: "Add menu: PRODUCT"),
                icon: UIImage(named: "AddProduct")!,
                color: UIScheme.productAddMenuColor,
                action: action
            )
        }
        
        static func eventItemWithAction(action: ItemAction?) -> MenuItem {
            return MenuItem(
                title: NSLocalizedString("EVENT",comment: "Add menu: EVENT"),
                icon: UIImage(named: "AddEvent")!,
                color: UIScheme.eventAddMenuColor,
                action: action
            )
        }
        
        static func promotionItemWithAction(action: ItemAction?) -> MenuItem {
            return MenuItem(
                title: NSLocalizedString("PROMOTION",comment: "Add menu: PROMOTION"),
                icon: UIImage(named: "AddPromotion")!,
                color: UIScheme.promotionAddMenuColor,
                action: action
            )
        }
        
        static func postItemWithAction(action: ItemAction?) -> MenuItem {
            return MenuItem(
                title: NSLocalizedString("POST",comment: "Add menu: POST"),
                icon: UIImage(named: "AddPost")!,
                color: UIScheme.postAddMenuColor,
                action: action
            )
        }
        
        static func inviteItemWithAction(action: ItemAction?) -> MenuItem {
            return MenuItem(
                title: NSLocalizedString("INVITE",comment: "Add menu: INVITE"),
                icon: UIImage(named: "AddInvite")!,
                color: UIScheme.inviteAddMenuColor,
                action: action
            )
        }
        
    }
 
}


//MARK: Private
extension AddMenuView {
    
    private func configure() {
        userInteractionEnabled = true
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        addSubview(startButton)
        startButton.addTarget(self, action: "toogleMenuTapped:", forControlEvents: UIControlEvents.ValueChanged)
        startButton.layer.zPosition = CGFloat(FLT_MAX)
        translatesAutoresizingMaskIntoConstraints = false

        decorationLayer.fillColor = UIScheme.tabbarBackgroundColor.CGColor
        layer.addSublayer(decorationLayer)
        /*
        let decorationAmount: CGFloat = 20 //decorationRect.height / 3.0
        let decorationMask = CALayer()
        decorationMask.bounds = decorationLayer.bounds
        decorationMask.backgroundColor = UIColor.blackColor().CGColor
        decorationMask.frame = decorationRect.rectsByDividing(decorationAmount, fromEdge: .MinYEdge).slice
        decorationLayer.mask = decorationMask
        */
    }
    
    private func applyExpandAnimation(duration: NSTimeInterval) {
        let expandAnimation: () -> Void = {
            self.startButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            for (idx, itemView) in self.menuItemViews.enumerate() {
                itemView.hidden = false
                let translation = -(itemView.bounds.height + self.itemsPadding) * CGFloat(idx + 1) - self.decorationInset
                let transform: CGAffineTransform =  CGAffineTransformMakeTranslation(0, translation)
                itemView.transform = transform
            }
        }
        let expandCompletion: (Bool) -> Void = { _ in
            UIView.animateWithDuration(0.2, animations: {
            for (_, itemView) in self.menuItemViews.enumerate() {
                    itemView.label.alpha = 1.0
                }
                }) { _ in
                    self.mExpanded = true
                    self.delegate?.addMenuView?(self, didExpand: self.expanded)
            }
        }
        if duration > 0 {
            UIView.animateWithDuration(duration, animations: expandAnimation, completion: expandCompletion)
        } else {
            expandAnimation()
            expandCompletion(true)
        }
    }

    private func applyCollapseAnimation(duration: NSTimeInterval) {
        let transform = CGAffineTransformIdentity
        let collapseAnimation: () -> Void = {
            self.startButton.transform = CGAffineTransformIdentity
            for (_, itemView) in self.menuItemViews.enumerate() {
                itemView.transform = transform
                itemView.label.alpha = 0.0
            }
        }
        let collapseCompletion: (Bool) -> Void = { _ in
            for (_, itemView) in self.menuItemViews.enumerate() {
                itemView.hidden = true
            }
            self.mExpanded = false
            self.delegate?.addMenuView?(self, didExpand: self.expanded)
        }
        if duration > 0 {
            UIView.animateWithDuration(duration, animations: collapseAnimation, completion: collapseCompletion)
        } else {
            collapseAnimation()
            collapseCompletion(true)
        }
    }

    
}


extension AddMenuView {
    private class AddMenuItemView: UIView {
        
        convenience init(direction: AnimationDirection, menuItem: MenuItem) {
            self.init(direction: direction, icon: menuItem.icon, color: menuItem.color, title: menuItem.title, action: menuItem.action)
        }
        
        init(direction: AnimationDirection, icon: UIImage, color: UIColor, title: String, action: ItemAction?) {
            switch direction {
            case .TopRight:
                layoutDirection = .LeftToRight
            }
            
            button = RoundButton(image: icon, fillColor: color,shadowColor: UIColor.darkGrayColor())
            button.bounds = CGRect(origin: CGPointZero, size: button.intrinsicContentSize())
            
            label = UILabel()
            label.text = title
            label.numberOfLines = 1
            label.sizeToFit()
            
            self.action = action
            
            super.init(frame: CGRectZero)
            translatesAutoresizingMaskIntoConstraints = false
            bounds = CGRect(origin: CGPointZero, size: contentSize())
            backgroundColor = UIColor.clearColor()
            userInteractionEnabled = true
            let actionSelector: Selector = "itemlTapped:"

            button.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.ValueChanged)
            addSubview(button)
            
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.whiteColor()
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: actionSelector))
            addSubview(label)
            
            switch layoutDirection {
            case .LeftToRight:
                label.textAlignment = .Left
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError(" \(__FUNCTION__) does not implemented")
        }
        
        override func intrinsicContentSize() -> CGSize {
            return contentSize()
        }
        
        let  button: RoundButton
        let  label: UILabel
        let layoutDirection: LayoutDirection
        let labelPadding: CGFloat = 10.0
        
        enum LayoutDirection {
            case LeftToRight
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            switch layoutDirection {
            case .LeftToRight:
                button.frame = CGRect(origin: CGPointZero, size: button.bounds.size)
                label.frame = CGRect(origin: CGPoint(
                    x: button.frame.maxX + labelPadding,
                    y: (bounds.height - label.bounds.height) / 2.0
                    ), size: label.bounds.size)
            }
        }
        
        @IBAction private func itemlTapped(sender: AnyObject) {
            if let menuView = superview as? AddMenuView {
                menuView.setExpanded(false, animated: true)
            }
            if let action = action {
                action()
            }
        }
        
        private func contentSize() -> CGSize {
            let height = max(label.bounds.height, button.bounds.height + labelPadding)
            let width = label.bounds.width + button.bounds.width + labelPadding
            return CGSize(width: width, height: height)
        }

        private let action: ItemAction?
    }
}
