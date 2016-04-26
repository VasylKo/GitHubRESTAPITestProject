//
//  PaymentViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 25/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

//This is common payment view controller with table view. The table has a header view wich can show payment transaction status on completion.
//Attention: table view delegaate and datasource are not set!
class CommonPaymentViewController: UIViewController, PaymentController {
    
    // MARK: - Internal ivar
    internal let paymentSystem: PaymentSystem
    @IBOutlet var tableView: UITableView?
    private var headerView : CommonTransactionStatusView?
    
    // MARK: - Init, PaymentController
    required init(paymentSystem: PaymentSystem) {
        self.paymentSystem = paymentSystem
        super.init(nibName: String(CommonPaymentViewController.self), bundle: nil)
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
            strongSelf.headerView?.showSuccess()
            strongSelf.paymentDidSuccess()
            }.onFailure { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.headerView?.showFailure()
                strongSelf.paymentDidFail(error)
        }
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    private func sizeHeaderToFit() {
        guard let headerView = tableView?.tableHeaderView else { return }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView?.tableHeaderView = headerView
    }
        
    // MARK: - Privvate implementation
    private func setupInterface() {
        //Hide back button while transaction is in action
        navigationItem.setHidesBackButton(true, animated: false)
        
        //Set header transaction status view
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(CommonTransactionStatusView.self), owner: nil, options: nil).first as? CommonTransactionStatusView {
            self.headerView = headerView
            tableView?.tableHeaderView = headerView
        }
    }
    
    //MARK: - Internal func
    internal func paymentDidSuccess() {
        //add close button to navigation bat
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: Selector("closeButtonTappedAfterSuccessPayment:"))
    }
    
    //Override for cuctome implementation
    internal func closeButtonTappedAfterSuccessPayment(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    internal func paymentDidFail(error: NSError) {
        //Enable back button, so user can go back and correct payment info
        navigationItem.setHidesBackButton(false, animated: true)
    }

}
