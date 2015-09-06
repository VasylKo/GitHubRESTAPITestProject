//
//  PostViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures


final class PostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let objectId = objectId {
            api().getPost(objectId).onSuccess { [weak self] post in
                
            }
        }
    }
    
    
    @IBOutlet weak var tableView: TableView!
    var objectId: CRUDObjectId?
}
