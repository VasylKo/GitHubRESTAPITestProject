//
//  ProductOrderViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 20/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Braintree
import Box

class ProductOrderViewController: XLFormViewController {
    private enum Tags : String {
        case Header = "Header"
        case Avaliability = "Avaliability"
        case Quantity = "Quantity"
        case Total = "Total"
        case ProceedToPay = "ProceedToPay"

    }
    
    // MARK: - Internal properties
    internal var product: Product?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.tintColor = UIScheme.mainThemeColor
        //self.title = NSLocalizedString("Order")
        
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.marketItemPurchase)
    }
    
    // MARK: - Builf XFForm
    func initializeForm() {
        guard let product = product else { return }
        
        let form = XLFormDescriptor(title: NSLocalizedString("Order", comment: "Order controller title"))
        
        //Product section
        let productSection = XLFormSectionDescriptor.formSection()
        productSection.title = ""
        form.addFormSection(productSection)
        
        //Product info  header row
        let orderHeaderRow: XLFormRowDescriptor = XLFormRowDescriptor(tag: Tags.Header.rawValue,
            rowType: XLFormRowDescriptorTypeOrderHeder)
        orderHeaderRow.cellConfigAtConfigure["name"] = product.name
        orderHeaderRow.cellConfigAtConfigure["projectIconURL"] = product.imageURL
        
        productSection.addFormRow(orderHeaderRow)
        
        self.form = form
    }
    
    // MARK: - Override Table View methods
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1
        }
        
        return UITableViewAutomaticDimension
    }
}