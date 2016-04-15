//
//  EPlusSelectPlanTableViewFooterView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

protocol EPlusSelectPlanTableViewFooterViewDelegate: class {
    func selectPlanTouched();
}

class EPlusSelectPlanTableViewFooterView: UIView {

    @IBAction func selectPlanTouched(sender: AnyObject) {
        delegate?.selectPlanTouched()
    }
    
    weak var delegate: EPlusSelectPlanTableViewFooterViewDelegate?
}
