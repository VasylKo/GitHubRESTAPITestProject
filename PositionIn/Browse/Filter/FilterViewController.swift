//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

class FilterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func didTapApply(sender: AnyObject) {
        Log.debug?.message("Should apply filter")
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        Log.debug?.message("Should cancel filter")
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBOutlet private weak var tableView: TableView!


}
