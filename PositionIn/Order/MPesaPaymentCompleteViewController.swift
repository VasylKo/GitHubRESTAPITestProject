//
//  MPesaPaymentCompleteViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 09/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

protocol MPesaPaymentCompleteDelegate {
    func closeButtonTapped(controller: MPesaPaymentCompleteViewController)
}

class MPesaPaymentCompleteViewController: XLFormViewController {

    private var quantity: Int?
    private var product: Product?
    private var headerView : MPesaIndicatorView!
    private var transactionId = ""
    private var cardItem: CardItem = .MPesa
    private var delegate: MPesaPaymentCompleteDelegate?
    
    //MARK: Initializers
    init(quantity: Int, product: Product, cardItem: CardItem = .MPesa, delegate: MPesaPaymentCompleteDelegate? = nil) {
        self.quantity = quantity
        self.product = product
        self.cardItem = cardItem
        self.delegate = delegate
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
        
        switch cardItem {
        case .MPesa:
            if let quantity = self.quantity, let price = product?.price, let objId = product?.objectId  {
                api().productCheckoutMpesa(NSNumber(float: price),
                    nonce: "", itemId: objId,
                    quantity: NSNumber(integer: quantity)).onSuccess {
                        [weak self] transactionId in
                        self?.transactionId = transactionId
                        self?.pollStatus()
                    }.onFailure(callback: { [weak self] _ in
                        self?.headerView.showFailure()
                        })
            }
        
        case .CreditDebitCard:
            self.headerView.showSuccess()
            customizeNavigationBar()
        }
    }
    
    @objc func pollStatus() {
        api().transactionStatusMpesa(transactionId).onSuccess { [weak self] status in
            self?.headerView.showSuccess()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
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
            let totalPrice = price * Float(quantity)
            donateProjectRow.cellConfigAtConfigure["totalPrice"] = NSNumber(float: totalPrice)
        }
        
        donateProjectRow.cellConfigAtConfigure["itemName"] = product?.name
        donateProjectRow.cellConfigAtConfigure["imageURL"] = product?.imageURL
        //TODO: add product pickUpAvailability data
        //donateProjectRow.cellConfigAtConfigure["pickUpAvailability"] = product?.entityDetails?.endData?.formattedAsTimeAgo()
        donateToSection.addFormRow(donateProjectRow)
        
        self.form = form
    }
    
    private func customizeNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "closeButtonPressed:")
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    func closeButtonPressed(sender: AnyObject) {
        delegate?.closeButtonTapped(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
