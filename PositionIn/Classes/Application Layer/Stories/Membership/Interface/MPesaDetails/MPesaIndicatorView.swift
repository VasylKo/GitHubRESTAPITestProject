//
//  MPesaIndicatorView.swift
//  PositionIn
//
//  Created by ng on 2/8/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MPesaIndicatorView: UIView {
    
    @IBOutlet weak var paymentCompletedLabel: UILabel!
    @IBOutlet private weak var paymentConfirmationLabel: UILabel!
    @IBOutlet private weak var successImageView: UIImageView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 200)
    }
    
    func showSuccess() {
        self.activityIndicatorView.stopAnimating()
        UIView.animateWithDuration(0.4) { [weak self]() -> Void in
            self?.successImageView.alpha = 1.0
            self?.paymentConfirmationLabel.alpha = 0.0
            self?.paymentCompletedLabel.alpha = 1.0
        }
    }
    
}
