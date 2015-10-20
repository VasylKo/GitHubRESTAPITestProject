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
        listController.excludeCommunityItems = m!.excludeCommunityItems
        listController.shoWCompactCells = m!.shoWCompactCells
        listController.browseMode = m!.browseMode
        var filter = listController.filter
        switch m!.filterType {
        case .User:
            filter.users = [ m!.objectId ]
        case .Community:
            filter.communities = [ m!.objectId ]
        }
        listController.filter = filter
        if let cfu = m!.childFilterUpdate {
            listController.applyFilterUpdate(cfu, canAffect: m!.canAffectOnFilter)
        }
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
    func browseController(controller: BrowseActionProducer, didSelectItem objectId: CRUDObjectId, type itemType: FeedItem.ItemType, data: Any?) {
        actionConsumer?.browseController(controller, didSelectItem: objectId, type: itemType, data: data)
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
    let filterType: FilterType
    var excludeCommunityItems = false
    var shoWCompactCells: Bool = true
    unowned var actionConsumer: BrowseActionConsumer
    let browseMode: BrowseModeTabbarViewController.BrowseMode
    var childFilterUpdate: SearchFilterUpdate?
    var canAffectOnFilter: Bool = true
    
    init(objectId: CRUDObjectId, actionConsumer: BrowseActionConsumer, browseMode: BrowseModeTabbarViewController.BrowseMode, filterType: FilterType = .User) {
        self.objectId = objectId
        self.browseMode = browseMode
        self.actionConsumer = actionConsumer
        self.filterType = filterType
    }
    
    enum FilterType {
        case User
        case Community
    }
}