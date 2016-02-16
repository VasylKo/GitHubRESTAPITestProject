//
//  AttendEventCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 15/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import PosInCore

class AttendEventCell: TableViewCell {

    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellAttendEventModel
        assert(m != nil, "Invalid model passed")
        self.attendEventSwitchControl.setOn(m!.attendEvent, animated: false)
        self.attendEventLabel.text = m!.title
    }
    
    @IBOutlet private weak var attendEventLabel: UILabel!
    @IBOutlet private weak var attendEventSwitchControl: UISwitch!
}
