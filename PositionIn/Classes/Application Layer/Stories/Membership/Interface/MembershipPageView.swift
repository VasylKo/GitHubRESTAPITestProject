//
//  MembershipPageView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 28/01/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipPageView: UIView {
    
    //MARK: Initializers
    
    private let pageCount: Int  //TODO make public available if need variable amount of steps
    
    init(pageCount : Int) {
        self.pageCount = pageCount
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        return CGSize(width: screenRect.size.width, height: 50)
    }
    
    //MARK: Drawing
    
    func redrawView(activeStep: Int) {
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.layer.sublayers?.removeAll()
        
        for var index: Int = 0; index < pageCount; ++index {

            let circleLayer: CAShapeLayer = CAShapeLayer()
            let circleXOrigin: Int = 36
            let circleDiameter: Int = 16
            let currentDiameter: Int = (index <= activeStep) ? circleDiameter : circleDiameter / 2
            let widthWithoutMargins = (self.frame.size.width - 36 * 2)
            let marginBetweenCircleCenters = widthWithoutMargins / CGFloat(self.pageCount - 1)
            
            let activeColor = UIColor(red: 208/255, green: 55/255, blue: 49/255, alpha: 1)
            let unactiveColor = UIColor(red: 243/255, green: 215/255, blue: 218/255, alpha: 1)
            
            let xOrigin = circleXOrigin + Int(marginBetweenCircleCenters - CGFloat(currentDiameter) / 2) * index
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: xOrigin,
                y: Int((self.frame.size.height - CGFloat(currentDiameter)) / 2), width: currentDiameter, height: currentDiameter),
                cornerRadius: CGFloat(currentDiameter) / 2).CGPath
            if (index <= activeStep) {
                circleLayer.fillColor = activeColor.CGColor
                circleLayer.strokeColor = activeColor.CGColor
            }
            else {
                circleLayer.fillColor = UIColor.clearColor().CGColor
                circleLayer.strokeColor = unactiveColor.CGColor
            }
            circleLayer.lineWidth = 2.0
            
            self.layer.addSublayer(circleLayer)
            
            if (index != 0) {
                let lineLayer = CAShapeLayer()
                let firstLineOrigin = circleXOrigin + (circleDiameter + 4)
                let marginBetweenCircleBorders = marginBetweenCircleCenters - CGFloat(circleDiameter / 2)
                
                lineLayer.path = UIBezierPath(roundedRect: CGRect(
                    x: firstLineOrigin + Int(marginBetweenCircleBorders * CGFloat(index - 1)),
                    y: Int((self.frame.size.height - 2) / 2),
                    width: Int(CGFloat(marginBetweenCircleCenters) - CGFloat(circleDiameter) * 2),
                    height: 2),
                    cornerRadius: CGFloat(2)).CGPath
                lineLayer.fillColor = (index <= activeStep) ? activeColor.CGColor : unactiveColor.CGColor
                self.layer.addSublayer(lineLayer)
            }
        }
    }
}
