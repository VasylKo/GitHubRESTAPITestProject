//
//  EPlusTableViewFooterView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

protocol EPlusTableViewFooterViewDelegate: class {
    func alreadyMemberButtonTouched()
}

class EPlusTableViewFooterView: UIView {
    
    @IBAction func alreadyMemberButtonTouched(sender: AnyObject) {
        self.delegate?.alreadyMemberButtonTouched()
    }
    
    weak var delegate: EPlusTableViewFooterViewDelegate?
}
