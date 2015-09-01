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
        let listTable = listController.tableView
        listTableHeightConstraint = NSLayoutConstraint(
            item: listTable,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: listTable.contentSize.height
        )
        listTable.addConstraint(listTableHeightConstraint)
        contentSizeObserver = KVObserver(subject: listTable, keyPath: "contentSize") {
            [weak listTable, weak self] _, _, _ in
            if  /*let newSize = newSize, */
                let table = listTable,
                let strongSelf = self {
                    strongSelf.listTableHeightConstraint.constant = table.contentSize.height
                    strongSelf.setNeedsLayout()
            }
        }
    }

    var childViewController: UIViewController {
        return listController
    }
    
    let listController = Storyboards.Main.instantiateBrowseListViewController()
    
    private var listTableHeightConstraint: NSLayoutConstraint!
    private var contentSizeObserver: KVObserver<String>!
}

public struct BrowseListCellModel: ProfileCellModel {
    let objectId: CRUDObjectId
}