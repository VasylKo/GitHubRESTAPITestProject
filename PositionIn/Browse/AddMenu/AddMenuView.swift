//
//  AddMenuView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class AddMenuView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        addSubview(startButton)
        let image = UIImage(named: "AddIcon")
        startButton.image = image
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startButton.frame = bounds
    }

    private let startButton = AddMenuButton()
    
}
