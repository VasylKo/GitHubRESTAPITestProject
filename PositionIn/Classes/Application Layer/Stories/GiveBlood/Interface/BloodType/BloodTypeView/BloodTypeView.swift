//
//  BloodTypeView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class BloodTypeView: UIView {
    
    //MARK: - Action
    
    @IBAction func bloodTypeButtonTapped(sender: UIButton) {
        bloodGroup = BloodGroup(rawValue: sender.tag)
        for view in self.subviews {
            if let button = view as? UIButton {
                button.selected = false
            }
        }
        sender.selected = true
    }
    
    //MARK: - UI
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        return CGSize(width: screenRect.size.width - 20, height: 174)
    }
    
    var bloodGroup: BloodGroup? {
        didSet {
            for view in self.subviews {
                if let v = view as? UIButton where v.tag == bloodGroup?.rawValue {
                    v.selected = true
                }
            }
        }
    }
}