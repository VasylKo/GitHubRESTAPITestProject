//
//  CommunityInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class CommunityHeaderCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? BrowseCommunityHeaderCellModel
        assert(m != nil, "Invalid model passed")
        captionLabel.text = m!.title
        
        self.infoButton.hidden = !m!.showInfo
        shouldCallInfoAction = m!.showInfo
        self.actionConsumer = m!.actionConsumer
        
        contentImageView.setImageFromURL(m!.url, placeholder: UIImage(named: "communityPlaceholder"))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.hnk_cancelSetImage()
    }
    
    weak var actionConsumer: CommunityFeedActionConsumer?
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        if shouldCallInfoAction, let actionConsumer = actionConsumer {
            actionConsumer.communityFeedInfoTapped()
        }
    }
    
    private var shouldCallInfoAction: Bool = false
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var contentImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
}
