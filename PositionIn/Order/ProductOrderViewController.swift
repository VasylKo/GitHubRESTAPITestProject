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
        self.title = NSLocalizedString("Order")
        
        //self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.marketItemPurchase)
    }
}
