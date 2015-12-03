//
//  SelectPaymentMethodController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm

class SelectPaymentMethodController: UIViewController, XLFormRowDescriptorViewController {
    
    var rowDescriptor: XLFormRowDescriptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let reuseIdentifier = NSStringFromClass(CardTableViewCell.self)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 80;
        
        self.tableView.registerNib(UINib(nibName: reuseIdentifier,
            bundle: nil),
            forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBOutlet weak var tableView: UITableView!
}


extension SelectPaymentMethodController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension SelectPaymentMethodController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CardItem.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(CardTableViewCell.self), forIndexPath: indexPath)
        
        if let cell = cell as? CardTableViewCell {
            if let cardItem = CardItem(rawValue: indexPath.row) {
                cell.cardName = CardItem.cardName(cardItem)
                cell.cardImage = CardItem.cardImage(cardItem)
            }
        }
        return cell
    }
}
