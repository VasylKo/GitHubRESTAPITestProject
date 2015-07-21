//
//  AddMenuButton.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class AddMenuButton: UIControl {

    convenience init() {
        self.init(image: UIImage())
    }
    
    convenience init(
        image: UIImage,
        fillColor: UIColor = UIColor.whiteColor(),
        shadowColor: UIColor = UIColor.lightGrayColor()
        ) {
            let frame = CGRect(origin: CGPointZero, size: image.size)
            self.init(frame: frame)
            self.fillColor = fillColor
            self.shadowColor = shadowColor
            self.image = image
            self.iconLayer.contents = image.CGImage
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    @IBInspectable var fillColor: UIColor? {
        set {
            if let color = newValue {
                bubbleLayer.fillColor = color.CGColor
            }
        }
        get {
            if let color = bubbleLayer.fillColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
    }
    
    
    @IBInspectable var shadowColor: UIColor? {
        set {
            if let color = newValue {
                bubbleLayer.shadowColor = color.CGColor
            }
        }
        get {
            if let color = bubbleLayer.shadowColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
    }
    
    
    @IBInspectable var image: UIImage? {
        didSet {
            iconLayer.contents = image?.CGImage
            setNeedsDisplay()
        }
    }

    private func configure() {
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        layer.addSublayer(bubbleLayer)
        layer.addSublayer(iconLayer)
        bubbleLayer.masksToBounds = false
        bubbleLayer.shadowOpacity = 1.0
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        iconLayer.contentsGravity = kCAGravityCenter
        iconLayer.masksToBounds = true
        bubbleLayer.shadowRadius = 1
    }
    
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        bubbleLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        bubbleLayer.frame = bounds
            let imageInsetsSize: CGFloat = bounds.width / 4.0
            let imageRect = CGRectInset(bounds, imageInsetsSize, imageInsetsSize)
            iconLayer.frame = imageRect
    }
    
    private let bubbleLayer = CAShapeLayer()
    private let iconLayer = CAShapeLayer()
    private let animationDuration: NSTimeInterval = 0.1
    private let animationScale: CGFloat = 0.85
}

//MARK: touches
extension AddMenuButton {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        animatedToSelectedState()
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        animatedToDeselectedState()
        sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        animatedToDeselectedState()
        sendActionsForControlEvents(UIControlEvents.TouchCancel)
    }
    
    
    private func animatedToSelectedState() {
        UIView.animateWithDuration(animationDuration) {
                let transform = CATransform3DMakeScale(self.animationScale, self.animationScale, 0)
                self.bubbleLayer.transform = transform
                self.iconLayer.transform = transform
        }
    }
    
    private func animatedToDeselectedState() {
        UIView.animateWithDuration(animationDuration) {
                let transform = CATransform3DMakeScale(1.0, 1.0, 0)
                self.bubbleLayer.transform = transform
                self.iconLayer.transform = transform
        }
    }
}

