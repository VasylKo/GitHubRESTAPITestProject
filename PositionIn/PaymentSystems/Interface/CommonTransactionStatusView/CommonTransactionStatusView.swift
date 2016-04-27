//
//  MPesaIndicatorView.swift
//  PositionIn
//
//  Created by ng on 2/8/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class CommonTransactionStatusView: UIView {
    
    @IBOutlet private weak var paymentCompletedLabel: UILabel!
    @IBOutlet private weak var paymentConfirmationLabel: UILabel!
    @IBOutlet private weak var paymentCompletedImageView: UIImageView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 110)
    }
    
    func showSuccess() {
        self.activityIndicatorView.stopAnimating()
        UIView.animateWithDuration(0.4) { [weak self]() -> Void in
            self?.paymentCompletedImageView.image = UIImage(named: "success_icon")
            self?.paymentCompletedImageView.alpha = 1.0

            self?.paymentCompletedLabel.alpha = 1.0
            self?.paymentCompletedLabel.text = NSLocalizedString("Payment Completed", comment: "MPesaIndicatorView")
            self?.paymentCompletedLabel.textColor = UIColor.bt_colorWithBytesR(119, g: 176, b: 53)
            
            self?.paymentConfirmationLabel.alpha = 0.0
        }
    }

    func showFailure() {
        self.activityIndicatorView.stopAnimating()
        UIView.animateWithDuration(0.4) { [weak self]() -> Void in
            self?.paymentCompletedImageView.image = UIImage(named: "failure_icon")
            self?.paymentCompletedImageView.alpha = 1.0
            
            self?.paymentCompletedLabel.alpha = 1.0
            self?.paymentCompletedLabel.text = NSLocalizedString("Payment Failed", comment: "MPesaIndicatorView")
            self?.paymentCompletedLabel.textColor = UIColor.bt_colorWithBytesR(228, g: 161, b: 50)
            
            self?.paymentConfirmationLabel.alpha = 0.0
        }
    }
}