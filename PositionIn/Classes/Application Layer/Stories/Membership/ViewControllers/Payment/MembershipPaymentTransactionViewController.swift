//
//  MembershipPaymentTransactionViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 26/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipPaymentTransactionViewController: CommonPaymentViewController {

    // MARK: - Rivate ivars
    private let router : MembershipRouter
    private let pageView = MembershipPageView(pageCount: 3)
    
    // MARK: - Init, PaymentController
    init (router: MembershipRouter, paymentSystem: PaymentSystem) {
        self.router = router
        super.init(paymentSystem: paymentSystem)
  
    }

    required init(paymentSystem: PaymentSystem) {
        fatalError("init(paymentSystem:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }
    
    
    private func setupInterface() {
        
        view.tintColor = UIScheme.mainThemeColor
        
        pageView.sizeToFit()
        pageView.redrawView(1)
        view.addSubview(pageView)
        
        //add pageView to bottom with constaints
        pageView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: pageView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: pageView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: pageView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: pageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: MembershipPageView.pageViewHeight)
        
        pageView.addConstraint(heightConstraint)
        view.addConstraints([bottomConstraint, trailingConstraint, leadingConstraint])
        
        //add pageView to bottom with constaints
        //guard let view = self.navigationController?.view else { return }
        //navigationController?.setToolbarHidden(false, animated: false)
        //navigationController?.toolbar.addSubview(pageView)
        
        /*
        view.addSubview(pageView)
 
        
*/
        
    }

}
