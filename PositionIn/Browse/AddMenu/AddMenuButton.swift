//
//  AddMenuButton.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class AddMenuButton: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setDefaults()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    @IBInspectable var shadowSize: CGFloat = 1 {
        didSet {
            bubbleLayer.shadowRadius = shadowSize
        }
    }

    private func configure() {
        layer.addSublayer(bubbleLayer)
        layer.addSublayer(iconLayer)
        bubbleLayer.masksToBounds = false
        bubbleLayer.shadowOpacity = 1.0
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)

        iconLayer.contents = UIImage(named: "MenuLogo")?.CGImage
        bubbleLayer.shadowColor = UIColor.blueColor().CGColor
        bubbleLayer.fillColor = UIColor.redColor().CGColor
    }
    
    private func setDefaults() {
        shadowSize = 5
    }
    
    
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        let insetsSize: CGFloat = shadowSize * 2
        let rectInsets = CGRectInset(bounds, insetsSize, insetsSize)
        bubbleLayer.path = UIBezierPath(ovalInRect: rectInsets).CGPath
        bubbleLayer.frame = bounds
        iconLayer.frame = CGRect(origin: CGPoint(x: shadowSize, y: shadowSize), size: rectInsets.size)
    }
    
    private let bubbleLayer = CAShapeLayer()
    private let iconLayer = CAShapeLayer()
    
}
