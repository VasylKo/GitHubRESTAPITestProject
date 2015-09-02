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
        selectionStyle = .None
        actionConsumer = m!.actionConsumer
        listController.actionConsumer = self
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
        listTable.scrollEnabled = false
    }

    var childViewController: UIViewController {
        return listController
    }
    
    weak var actionConsumer: BrowseActionConsumer?
    
    let listController = Storyboards.Main.instantiateBrowseListViewController()
    
    private var listTableHeightConstraint: NSLayoutConstraint!
}

extension BrowseListTableViewCell: BrowseActionConsumer {
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType) {
        actionConsumer?.browseController(controller, didSelectItem: objectId, type: itemType)
    }
    
    func browseControllerDidChangeContent(controller: BrowseActionProducer) {
        //TODO: use constraint outlet instead of magic number
        listTableHeightConstraint.constant = listController.tableView.contentSize.height + 20 // Padding top
        superview?.setNeedsLayout()
        
        actionConsumer?.browseControllerDidChangeContent(controller)
    }
    
}


public struct BrowseListCellModel: ProfileCellModel {
    let objectId: CRUDObjectId
    unowned var actionConsumer: BrowseActionConsumer
}