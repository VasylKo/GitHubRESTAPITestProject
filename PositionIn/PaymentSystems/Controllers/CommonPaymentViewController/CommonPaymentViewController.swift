//
//  PaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 25/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

/*
    This is common payment view controller with table view. The table has a header view wich cab show payment transaction status.
*/

class CommonPaymentViewController: UITableViewController, PaymentController {
    
    // MARK: - Internal ivar
    internal let paymentSystem: PaymentSystem
    
    private var headerView : CommonTransactionStatusView?
    
    // MARK: - Init, PaymentController
    required init(paymentSystem: PaymentSystem) {
        self.paymentSystem = paymentSystem
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        
        paymentSystem.purchase().onSuccess { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.paymentDidSuccess()
            }.onFailure { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.paymentDidFail(error)
        }
        
    }
        
    // MARK: - Privvate implementation
    private func setupInterface() {
        //Hide back button while transaction is in action
        navigationItem.setHidesBackButton(true, animated: false)
        
        //Set header transaction status view
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(CommonTransactionStatusView.self), owner: nil, options: nil).first as? CommonTransactionStatusView {
            self.headerView = headerView
            tableView.tableHeaderView = headerView
        }
    }
    
    //MARK: - Internal func
    internal func paymentDidSuccess() {
        headerView?.showSuccess()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector("closeButtonTappedAfterSuccessPayment:"))
    }
    
    internal func closeButtonTappedAfterSuccessPayment(sender: AnyObject) {
        print("Father")
    }
    
    internal func paymentDidFail(error: NSError) {
        headerView?.showFailure()
        //Enable back button, so user can go back and correct payment info
        navigationItem.setHidesBackButton(false, animated: true)
    }

}
