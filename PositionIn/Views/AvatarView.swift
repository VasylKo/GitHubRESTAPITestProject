//
//  AvatarView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import Haneke

@IBDesignable
class AvatarView: UIView {
    func setImageFromURL(url: NSURL?) {
        layoutIfNeeded()
        imageView.setImageFromURL(url, placeholder: UIImage(named: "AvatarPlaceholder"))
    }
    
    func cancelSetImage() {
        imageView.hnk_cancelSetImage()
    }
    
    var image: UIImage? {
        set {
            imageView.image = image
        }
        get {
            return imageView.image
        }
        
    }
    
    @IBInspectable
    var borderColor: UIColor?  {
        didSet {
            borderLayer.strokeColor = borderColor?.CGColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            borderLayer.lineWidth = borderWidth * 2
        }
    }
    
    init(image: UIImage) {
        let imageSize = max(image.size.width, image.size.height)
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: imageSize, height: imageSize)))
        configure()
        setDefaults()
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    
    private func configure() {
        layer.addSublayer(borderLayer)
        addSubview(imageView)
         // Smoothens the border
        borderLayer.contentsScale = 2.0 * UIScreen.mainScreen().scale
        // Explicitly set the image
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.image = image
        // Mask the image
        imageView.layer.mask = maskLayer
    }
    
    private func setDefaults() {
        // Keep the images dimensions
        imageView.contentMode = .ScaleAspectFill
        // Set default border widths
        borderWidth = 1.0
        borderColor = .whiteColor()
    }

    // Layouts the subview
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    // Layouts the layers
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        // Makes room for the the border
        let insetsSize = borderWidth
        let rectInsets = CGRectInset(bounds, insetsSize, insetsSize)
        
        // Update the path to fit the frame
        maskLayer.path = UIBezierPath(ovalInRect: rectInsets).CGPath
        borderLayer.path = maskLayer.path
        borderLayer.frame = bounds
    }
    
    private let imageView = UIImageView(image: UIImage(named: "AvatarPlaceholder"))
    private let borderLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    
    override func prepareForInterfaceBuilder() {
        image = UIImage(named: "MainMenuPeople", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: self.traitCollection)
    }
}
