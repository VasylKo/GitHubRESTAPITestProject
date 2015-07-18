//
//  TableViewSuite.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

public protocol TableViewCellModel {
    
}

public protocol TableViewChildViewControllerCell {
    var childViewController: UIViewController { get }
}


public class TableViewCell: UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // this prevents the temporary unsatisfiable constraint state that the cell's contentView could
        // enter since it starts off 44pts tall
        contentView.autoresizingMask |= .FlexibleHeight;
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // this prevents the temporary unsatisfiable constraint state that the cell's contentView could
        // enter since it starts off 44pts tall
        self.contentView.autoresizingMask |= .FlexibleHeight;
    }
    
    public func setModel<M: TableViewCellModel>(model: M) {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    //MARK: Determining height of cells that use Auto Layout
    func heightFor(width: CGFloat, separatorStyle: UITableViewCellSeparatorStyle) -> CGFloat {
        // set cell width
        bounds = CGRect(origin: CGPointZero, size: CGSize(width: width, height: bounds.height))
        
        // now force layout on cell view hierarchy using specified width
        // this makes sure any preferredMaxLayoutWidths, etc. are set
        self.layoutIfNeeded()
        
        // height computed based upon Auto Layout constraints in contentView
        let contentViewHeight = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        if contentViewHeight == 0 {
            // didn't seem like there were Auto Layout constraints that defined contentView's height
            return UITableViewAutomaticDimension
        } else {
            // +0.5 or 1.0 to account for cell separator http://tomabuct.com/post/73484699239/uitableviews-in-
            let separatorHeight = (separatorStyle == .None) ? 0 : (1.0 / UIScreen.mainScreen().scale)
            return contentViewHeight + separatorHeight
        }
    }
    
    internal(set) public var sizingCell: Bool = false
}


public class TableView: UITableView {
    public var state: State
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        state = .Loading
        super.init(frame: frame, style: style)
    }
    
    public required init(coder aDecoder: NSCoder) {
        state = .Loading
        super.init(coder: aDecoder)
    }
    
    public enum State {
        case Loading // Initial loading state. Pull to refresh header will not show.
        case Loaded /// Normal state. Nothing is currently loading.
        case Refreshing /// Refreshing after a pull-to-refresh. The refreshHeaderView will be showing.
        case Errored /// Network request errored.
    }
    
}

public class TableViewDataSource: NSObject {
    /// Set as the parent view controller of any cells implementing TableViewChildViewControllerCell.
    public weak var parentViewController: UIViewController?
    
    //MARK: Helpers

    public func reloadVisibleCell<M: TableViewCellModel>(model: M, tableView: UITableView) {
        //TODO: implement
    }
    
    //MARK: Configuration
    
    public func tableView(tableView: UITableView, configureCell cell: TableViewCell, forIndexPath indexPath: NSIndexPath) {
        let model: TableViewCellModel = self.tableView(tableView, modelForIndexPath: indexPath)
//        cell.setModel(self.tableView(tableView, modelForIndexPath: indexPath))
    }
    
    //MARK: Reuse Identifiers
    
    public func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    //MARK: Models
    
    public func tableView<M: TableViewCellModel>(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> M {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    
}

extension TableViewDataSource: UITableViewDataSource {
    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = self.tableView(tableView, reuseIdentifierForIndexPath: indexPath)
        let cell = tableView .dequeueReusableCellWithIdentifier(reuseId) as! TableViewCell
        self.tableView(tableView, configureCell: cell, forIndexPath: indexPath)
        return cell
    }
}

extension TableViewDataSource: UITableViewDelegate {
    @objc public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView as? TableView != nil) {
            return UITableViewAutomaticDimension
        } else {
            fatalError("This can only be the delegate of a TableView")
        }
    }
}