//
//  CommunityInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

final class CommunityActionCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as! BrowseCommunityActionCellModel
        community = m.community
        actionConsumer = m.actionConsumer
        Log.debug?.value(m.actions)
        for btn in actionButtons {
            btn.removeFromSuperview()
        }
        
        actionButtons = m.actions.map { action in
            let button = UIButton()
            button.tag = action.rawValue
            button.setTitle(action.displayText(), forState: .Normal)
            button.setTitleColor(UIScheme.communityActionColor, forState: .Normal)
            button.titleLabel?.font = UIScheme.appMediumFontOfSize(14)
            button.addTarget(self, action: "executeAction:", forControlEvents: UIControlEvents.TouchUpInside)
            self.contentView.addSubview(button)
            return button
        }
        setNeedsLayout()
    }
    
    weak var actionConsumer: BrowseCommunityActionConsumer?
    var community: Community?
    
    @IBAction func executeAction(sender: UIButton) {
        if let action = BrowseCommunityViewController.Action(rawValue: sender.tag) {
            actionConsumer?.executeAction(action, community: community ?? Community())
        }
    }
    
    
    private var actionButtons: [UIButton] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = frame.width / CGFloat((actionButtons).count)
        let height = frame.height
        for (idx, btn) in actionButtons.enumerate() {
            btn.frame = CGRect(x: width * CGFloat(idx), y: 0, width: width, height: height)
        }
    }

}
