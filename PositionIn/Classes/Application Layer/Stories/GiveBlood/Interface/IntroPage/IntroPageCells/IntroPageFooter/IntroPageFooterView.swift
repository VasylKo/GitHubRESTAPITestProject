//
//  IntroPageFooterView.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/7/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

protocol IntroPageTableViewFooterViewDelegate: class {
    func giveBloodButtonPressed();
    func skipThisStepButtonPressed();
}

class IntroPageFooterView: UIView {

    weak var delegate: IntroPageTableViewFooterViewDelegate?
    
    @IBAction func giveBloodButtonPressed(sender: AnyObject) {
        delegate?.giveBloodButtonPressed()
    }
    
    @IBAction func skipThisStepButtonPressed(sender: AnyObject) {
        delegate?.skipThisStepButtonPressed()
    }
}