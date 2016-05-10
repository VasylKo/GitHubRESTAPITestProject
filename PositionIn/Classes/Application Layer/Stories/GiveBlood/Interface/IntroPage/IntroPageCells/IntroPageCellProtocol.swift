//
//  IntroPageCellProtocol.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/6/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

protocol GiveBloodIntroCellDelegate: class {
    func readMoreButtonPressedOnCell(cell: UITableViewCell)
}

protocol GiveBloodIntroCell: class {
    weak var delegate: GiveBloodIntroCellDelegate? { get set }
    var showMore: Bool { get set }
}