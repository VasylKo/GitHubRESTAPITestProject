//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class AddPromotionViewController: XLFormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func didTapPost(sender: AnyObject) {
        Log.debug?.message("Should post")
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
    }
    

}
