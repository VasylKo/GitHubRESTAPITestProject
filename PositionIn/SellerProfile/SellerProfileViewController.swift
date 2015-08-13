//
//  SellerProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 31/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore


final class SellerProfileViewController: UIViewController {
    
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        
        let url = NSURL(string: "https://pbs.twimg.com/profile_images/3255786215/509fd5bc902d71141990920bf207edea.jpeg")!
        avatarView.setImageFromURL(url)

    }
    
    
    private lazy var dataSource: SellerProfileDataSource = {
        let dataSource = SellerProfileDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}

extension SellerProfileViewController {
    internal class SellerProfileDataSource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            super.configureTable(tableView)
        }
        
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 4
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ActionCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            let title: String
            switch indexPath.row {
            case 0:
                title = "SendMessage"
            case 1:
                title = "Call"
            case 2:
                title = "Product Inventory"
            case 3:
                title = "Navigate"
            default:
                title = ""
            }
            let model = TableViewCellImageTextModel(title: title, imageName: "MainMenuMessages")
            return model
        }
        
        
        override func nibCellsId() -> [String] {
            return [ActionCell.reuseId()]
        }
        

        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
}

