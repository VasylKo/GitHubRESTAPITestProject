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
    // MARK: - Private properties
    private var donation: Order?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donation"
    }
}