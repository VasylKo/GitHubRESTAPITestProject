//
//  AddMenuView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class AddMenuView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    var expanded: Bool = false {
        didSet {
            if expanded {
                applyExpandAnimation()
            } else {
                applyCollapseAnimation()
            }
        }
    }
    var direction: AnimationDirection = .TopRight
    
    func setItems(items: [MenuItem]) {
        let menuItem = MenuItem(title: NSLocalizedString("PRODUCT",comment: "Add menu: PRODUCT"), icon: UIImage(named: "AddProduct")!, color: UIColor.yellowColor())
        
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
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startButton.frame = bounds
    }

    
    private var menuItemViews: [AddMenuItemView] = []
    private let startButton = RoundButton(image: UIImage(named: "AddIcon")!)
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
    }
 
    @IBAction func toogleMenuTapped(sender: AnyObject) {
        println("toogleMenuTapped")
    }

}


//MARK: Private
extension AddMenuView {
    
    private func configure() {
        userInteractionEnabled = true
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        addSubview(startButton)
        startButton.addTarget(self, action: "toogleMenuTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    private func applyExpandAnimation() {
        
    }

    private func applyCollapseAnimation() {
        
    }

    
}


extension AddMenuView {
    private class AddMenuItemView: UIView {
        
        convenience init(direction: AnimationDirection, menuItem: MenuItem) {
            self.init(direction: direction, icon: menuItem.icon, color: menuItem.color, title: menuItem.title)
        }
        
        init(direction: AnimationDirection, icon: UIImage, color: UIColor, title: String) {
            switch direction {
            case .TopRight:
                layoutDirection = .LeftToRight
            }
            
            button = RoundButton(image: icon, fillColor: color)
            button.bounds = CGRect(origin: CGPointZero, size: button.intrinsicContentSize())
            
            label = UILabel()
            label.text = title
            label.numberOfLines = 1
            label.sizeToFit()
            
            super.init(frame: CGRectZero)
            
            bounds = CGRect(origin: CGPointZero, size: contentSize())
            backgroundColor = UIColor.clearColor()
            userInteractionEnabled = true
            let actionSelector: Selector = "itemlTapped:"

            button.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.TouchUpInside)
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
        
        required init(coder aDecoder: NSCoder) {
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
            println("Tap")
        }
        
        private func contentSize() -> CGSize {
            let height = max(label.bounds.height, button.bounds.height + labelPadding)
            let width = label.bounds.width + button.bounds.width + labelPadding
            return CGSize(width: width, height: height)
        }

    }
}

