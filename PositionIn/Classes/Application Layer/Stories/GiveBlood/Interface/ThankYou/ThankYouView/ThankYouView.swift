//
//  ThankYouView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 12/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

protocol ThankYouViewDelegate: class {
    func viewBloodCenters()
}

class ThankYouView: UIView {
    
    //MARK: - Action
    
    @IBAction func viewCenterButtonTapped(sender: UIButton) {
        delegate?.viewBloodCenters()
    }
    
    //MARK: - UI
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        return CGSize(width: screenRect.size.width - 20, height: 300)
    }
    
    //MARK: - Support
 
    weak var delegate: ThankYouViewDelegate?
    @IBOutlet weak var viewCenterButton: UIButton! {
        didSet {
            viewCenterButton.layer.cornerRadius = 2
            viewCenterButton.layer.masksToBounds = false
            viewCenterButton.layer.shadowColor = UIColor.blackColor().CGColor
            viewCenterButton.layer.shadowOffset = CGSize(width: 0, height: 1)
            viewCenterButton.layer.shadowOpacity = 0.1
        }
    }
}
