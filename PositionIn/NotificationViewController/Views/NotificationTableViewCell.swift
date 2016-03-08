//
//  NotificationTableViewCelll.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureWithNotification(notification: SystemNotification) {
        self.titleLabel.text = notification.title ?? NSLocalizedString("Notification")
        self.dateLabel.text = notification.createdDate?.formattedAsTimeAgo()
    }
    
}
