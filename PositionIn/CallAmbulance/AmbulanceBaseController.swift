//
//  AmbulanceBaseController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 29/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class AmbulanceBaseController: UIViewController {
    
    var ambulanceRequestObjectId: CRUDObjectId?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: .Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cancelRequestButtonTapped(sender: AnyObject) {
        if let objID = self.ambulanceRequestObjectId {
            api().deleteAmbulanceRequest(objID).onSuccess(callback: {[weak self] in
                self?.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
    }
}
