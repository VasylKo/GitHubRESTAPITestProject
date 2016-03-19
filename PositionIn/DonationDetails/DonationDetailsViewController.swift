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
    
    // MARK: - Intenal properties
    internal var donation: Order?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Private functions
    private func configure() {
        title = NSLocalizedString("Donation")
        
        productImage?.setImageFromURL(donation?.entityDetails?.imageURL, placeholder: UIImage(named: "market_img_default"))
        donatedToLabel?.text = donation?.entityDetails?.name
        paymentMethodLabel?.text = donation?.paymentMethod?.description
        paymentDateLabel?.text = donation?.paymentDate?.formattedAsTimeAgo()
        totalLabel?.text = AppConfiguration().currencyFormatter.stringFromNumber(donation?.price ?? 0.0) ?? ""
    }
}