//
//  DueDateView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class DueDateView: UIView {
    
    //MARK: - Actions
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        let sourceTimeZone = NSTimeZone(name: "UTC")
        let destinationTimeZone = NSTimeZone.localTimeZone()
        
        let sourceGMTOffset = sourceTimeZone?.secondsFromGMT
        let destinationGMTOffset = destinationTimeZone.secondsFromGMT
        var interval = destinationGMTOffset - sourceGMTOffset!
        interval += 60 * 60 * 24 - 1 //set the last second of today
        dueDate = datePicker.date.dateByAddingTimeInterval(NSTimeInterval(interval))

        dateButton.setTitle(dateFormatter.stringFromDate(datePicker.date), forState: .Normal)
    }
    
    @IBAction func setDatePressed(sender: UIButton) {
        sender.selected = !sender.selected
        UIView.animateWithDuration(1, delay: 0, options: .BeginFromCurrentState,
                                   animations:{ [weak self] in
                                    self?.datePicker.alpha = sender.selected ? 1 : 0
                                    self?.sizeToFit()},
                                   completion: nil)
        
    }
    
    //MARK: - UI
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        let viewHeight: CGFloat = 94
        let height = dateButton.selected ? (viewHeight + self.datePicker.frame.size.height - 4) : viewHeight
        return CGSize(width: screenRect.size.width - 20, height: height)
    }
    
    //MARK: - Support
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return dateFormatter
    }()
    
    var dueDate: NSDate? {
        didSet {
            if let date = dueDate {
                datePicker.date = date
                dateButton.setTitle(dateFormatter.stringFromDate(date), forState: .Normal)
            }
        }
    }
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.datePickerMode = .Date
            datePicker.minimumDate = NSDate()
        }
    }
}