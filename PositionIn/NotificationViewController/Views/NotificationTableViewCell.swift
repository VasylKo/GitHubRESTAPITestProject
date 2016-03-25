//
//  NotificationTableViewCelll.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit


class NotificationTableViewCell: UITableViewCell {

    @IBOutlet private weak var notificationImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func configureWithNotification(notification: SystemNotification) {
        
        //TODO: should add types
        var image : UIImage
        switch notification.type {
        case .AmbulanceOnTheWay:
            fallthrough
        case .AmbulanceCancelled:
            image =  (notification.isRead == true) ?  UIImage(named:"ic_ambulance_notification_read")!
                : UIImage(named:"ic_ambulance_notification_unread")!
        case .MPESAPaymentCompleted:
            image = UIImage(named:"AddIcon")!
            break
        case .MPESAPaymentFailed:
            image = UIImage(named:"AddIcon")!
            break
        case .MembershipIsAboutToExpired:
            image = UIImage(named:"AddIcon")!
            break
        case .MembershipExpired:
            image = UIImage(named:"AddIcon")!
            break
        case .OrderDelivered:
            image = UIImage(named:"AddIcon")!
            break
        default:
            image = UIImage(named:"AddIcon")!
        }
        
        self.notificationImageView.image = image
        
        self.titleLabel.text = notification.title ?? NSLocalizedString("Notification")
        self.dateLabel.textColor = (notification.isRead == true) ? UIColor.grayColor() : UIColor.redColor()
        
        self.dateLabel.text = notification.createdDate?.formattedAsFeedTime()
    }
}
