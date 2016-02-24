//
// Created by Max Stoliar on 1/17/16.
// Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class MpesaViewController : XLFormViewController, PaymentProtocol {
    var amount: Int?
    var quantity: Int?
    var itemId: String?
    var product: Product?
    var productName: String?
    var delegate: PaymentReponseDelegate?
    
    private var headerView : MPesaIndicatorView!
    private var transactionId = ""
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupInterface()
        self.initializeForm()
        
        let amount = String(self.amount ?? 0)
        api().donateCheckoutMpesa(amount, nonce: "").onSuccess { [weak self] transactionId in
            self?.transactionId = transactionId
            self?.pollStatus()
            }.onFailure(callback: { [weak self] _ in
                self?.headerView.showFailure()
            })
    }
    
    @objc func pollStatus() {
        api().transactionStatusMpesa(transactionId).onSuccess{ [weak self] status in
            self?.headerView.showSuccess()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                if self != nil {
                    appDelegate().sidebarViewController?.executeAction(SidebarViewController.defaultAction)
                }
            }
            }.onFailure { [weak self] error in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self?.pollStatus()
                }
        }
    }
    
    func setupInterface() {
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
        
        let donateProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeDonate)
        donateProjectRow.cellConfigAtConfigure["name"] = self.product?.name
        donateProjectRow.cellConfigAtConfigure["projectIconURL"] = self.product?.imageURL
        donateToSection.addFormRow(donateProjectRow)
        let totalProjectRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeTotal)
        totalProjectRow.cellConfigAtConfigure["price"] = "KSH \(self.amount ?? 0)"
        donateToSection.addFormRow(totalProjectRow)
        
        self.form = form
    }
}
