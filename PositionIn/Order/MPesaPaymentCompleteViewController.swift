//
//  MPesaPaymentCompleteViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 09/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class MPesaPaymentCompleteViewController: XLFormViewController {

    var showSuccess:Bool = false
    private var quantity: Int?
    private var product: Product?
    private var headerView : MPesaIndicatorView!
    private var transactionId = ""
    
    //MARK: Initializers

    init(quantity: Int, product: Product) {
        self.quantity = quantity
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        self.initializeForm()
        
        if let quantity = self.quantity, let price = product?.price, let objId = product?.objectId where !self.showSuccess  {
            api().productCheckoutMpesa(NSNumber(float: price), nonce: "", itemId: objId, quantity: NSNumber(integer: quantity)).onSuccess {
                [weak self] transactionId in
                self?.transactionId = transactionId
                self?.pollStatus()
            }
        }
        
        if (showSuccess) {
            self.headerView.showSuccess()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @objc func pollStatus() {
        api().transactionStatusMpesa(transactionId).onSuccess { [weak self] status in
            self?.headerView.showSuccess()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            }.onFailure { [weak self] error in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self?.pollStatus()
                }
        }
    }
    
    func setupInterface() {
        view.tintColor = UIScheme.mainThemeColor
        
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(MPesaIndicatorView.self), owner: nil, options: nil).first as? MPesaIndicatorView {
            self.headerView = headerView
            self.tableView.tableHeaderView = headerView
        }
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Payment", comment: "Donate"))
        
        //Donate section
        let donateToSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(donateToSection)
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeMarketPaymentView)
        if let product = product,
        quantity = quantity, price = product.price{
            donateProjectRow.cellConfigAtConfigure["quantity"] = NSNumber(integer: quantity)
            donateProjectRow.cellConfigAtConfigure["price"] = NSNumber(float:price)
        }
        donateProjectRow.cellConfigAtConfigure["imageURL"] = product?.imageURL
        donateToSection.addFormRow(donateProjectRow)
        
        self.form = form
    }
}
