//
//  DueDateView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class DueDateView: UIView {
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        dueDate = datePicker.date
        dateButton.setTitle(self.stringFromDate(datePicker.date), forState: .Normal)
    }
    
    private func stringFromDate(date : NSDate?) -> String {
        if date != nil {
            return dateFormatter.stringFromDate(date!)
        } else {
            return String()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        let viewHeight: CGFloat = 94
        let height = dateButton.selected ? (viewHeight + self.datePicker.frame.size.height - 4) : viewHeight
        return CGSize(width: screenRect.size.width - 20, height: height)
    }
    
    @IBAction func setDatePressed(sender: UIButton) {
        sender.selected = !sender.selected
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations:{ [weak self] in
                                    self?.datePicker.alpha = sender.selected ? 1 : 0
                                    self?.sizeToFit()},
                                   completion: nil)
        
    }
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        let format = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())
        
        if format?.rangeOfString("a") != nil {
            dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        }
        else {
            dateFormatter.dateFormat = "dd MMM, yyyy h:mm a"
        }
        
        return dateFormatter
    }()
    
    var dueDate: NSDate?
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.minimumDate = NSDate()
        }
    }
}