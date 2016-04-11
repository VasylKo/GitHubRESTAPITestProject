//
//  DonationDetailsViewController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 03/03/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class DonationDetailsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var donatedToLabel: UILabel?
    @IBOutlet weak var paymentMethodLabel: UILabel?
    @IBOutlet weak var paymentDateLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var transactionIDLabel: UILabel?
    
    // MARK: - Intenal properties
    internal var donation: Order?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics(AnalyticsLabels.walletDonationsDetails)
    }
    
    // MARK: - Private functions
    private func configure() {
        title = NSLocalizedString("Donation")
        
        setProductImage()
        donatedToLabel?.text = donation?.entityDetails?.name
        paymentMethodLabel?.text = donation?.paymentMethod?.description
        transactionIDLabel?.text = donation?.transactionId
        paymentDateLabel?.text = donation?.paymentDate?.formattedAsTimeAgo()
        totalLabel?.text = AppConfiguration().currencyFormatter.stringFromNumber(donation?.price ?? 0.0) ?? ""
    }
    
    
    private func setProductImage() {
        guard let donation = donation else {
            productImage?.setImageFromURL(nil, placeholder: UIImage(named: "market_img_default"))
            return
        }
        
        var placeholderImage: UIImage?
        
        switch donation.type {
        case .Emergency:
             placeholderImage = UIImage(named: "PromotionDetailsPlaceholder")
        case .Project:
            placeholderImage = UIImage(named: "hardware_img_default")
        case .Donation:
            placeholderImage = UIImage(named: "krfc")
        default:
            placeholderImage = UIImage(named: "market_img_default")
        }
        
        //set image for donation
        productImage?.setImageFromURL(donation.entityDetails?.imageURL, placeholder: placeholderImage)
    }
}
