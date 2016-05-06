//
//  GiveBloodAlertView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 06/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

@objc protocol GiveBloodAlertViewDelegate: class {
    func yesTapped()
    func noTapped()
}

class GiveBloodAlertView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        if self.subviews.count == 0 {
            self.clipsToBounds = true
            view = NSBundle.mainBundle().loadNibNamed("GiveBloodAlertView", owner: self, options: nil)[0] as? GiveBloodAlertView
            if let view = view {
                view.frame = self.bounds
                self.addSubview(view)
            }
        }
        
        self.view?.noButton.layer.borderColor = UIScheme.tabbarBackgroundColor.CGColor
        self.view?.yesButton.layer.borderColor = UIScheme.tabbarBackgroundColor.CGColor
    }
    
    var title: String? {
        didSet {
            view?.titleLabel.text = title
        }
    }
    
    @IBOutlet weak var delegate: AnyObject? {
        didSet {
            view?.delegate = delegate
        }
    }
    
    private var view: GiveBloodAlertView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBAction private func noTapped(sender: AnyObject) {
        self.delegate?.noTapped()
    }
    
    @IBAction private func yesTapped(sender: AnyObject) {
        self.delegate?.yesTapped()
    }
}
