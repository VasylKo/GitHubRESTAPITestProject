//
//  SellerProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 31/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

//    @availability(*, unavailable)
final class SellerProfileViewController: ProfileListViewController {
    
    @IBOutlet private weak var avatarView: AvatarView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        let url = NSURL(string: "https://pbs.twimg.com/profile_images/3255786215/509fd5bc902d71141990920bf207edea.jpeg")!
        avatarView.setImageFromURL(url)

    }
    
    

}


