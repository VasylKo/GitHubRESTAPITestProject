//
//  BrowseListTableViewCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore


final class BrowseListTableViewCell: TableViewCell, TableViewChildViewControllerCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? BrowseListCellModel
        assert(m != nil, "Invalid model passed")
        var filter = listController.filter
        filter.users = [ m!.objectId ]
        listController.filter = filter
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareChildController()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareChildController()
    }
    
    private func prepareChildController() {
        contentView.addSubViewOnEntireSize(listController.view)
    }

    var childViewController: UIViewController {
        return listController
    }
    
    let listController = Storyboards.Main.instantiateBrowseListViewController()
}

public struct BrowseListCellModel: ProfileCellModel {
    let objectId: CRUDObjectId
}