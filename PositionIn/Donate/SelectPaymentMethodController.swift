//
//  SelectPaymentMethodController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import Box

class SelectPaymentMethodController: UIViewController, XLFormRowDescriptorViewController {
    
    var rowDescriptor: XLFormRowDescriptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reuseIdentifier = NSStringFromClass(CardTableViewCell.self)
        
        self.tableView = UITableView(frame: CGRectZero, style: .Plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        self.tableView.registerNib(UINib(nibName: reuseIdentifier,
            bundle: nil),
            forCellReuseIdentifier: reuseIdentifier)
        self.view.addSubview(self.tableView)
        
        self.infoLabel = UILabel(frame: CGRectZero)
        self.infoLabel.text = NSLocalizedString("Information is sent over a secure connection.", comment: "")
        self.infoLabel.font = UIFont(name: "Helvetica", size: 14)
        self.view.addSubview(self.infoLabel)
     
        self.title = NSLocalizedString("Select Payment Method", comment: "")
        self.view.backgroundColor = UIColor.bt_colorWithBytesR(245, g: 245, b: 245)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var frame = self.tableView.frame
        frame.origin.y = 10
        frame.size = self.tableView.contentSize
        frame.size.width = self.view.frame.size.width
        self.tableView.frame = frame
        
        self.infoLabel.sizeToFit()
        frame = self.infoLabel.frame
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2
        frame.origin.y = self.view.frame.size.height - frame.size.height - 10
        self.infoLabel.frame = frame
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var infoLabel: UILabel!
}


extension SelectPaymentMethodController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cardItem = CardItem(rawValue: indexPath.row) {
            self.rowDescriptor?.value = Box(cardItem)
        }
        
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
                cell.cardDescription = CardItem.cardDescription(cardItem)
                cell.cardImage = CardItem.cardImage(cardItem)
            }
            cell.layoutMargins = UIEdgeInsetsZero
        }
        return cell
    }
}
