//
//  NSDate+pickUpAvaliabilityString.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 26/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

extension NSDate {
    
    private var dateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE dd yyyy, HH:mm"
        return dateFormatter
    }
    
    func toDateString(date: NSDate) -> String {
        let startDateString = dateFormatter.stringFromDate(self)
        let endDateString = dateFormatter.stringFromDate(date)
        let pickUpAvaliabilityString = "\(startDateString) to \(endDateString)"
        return pickUpAvaliabilityString
    }
}