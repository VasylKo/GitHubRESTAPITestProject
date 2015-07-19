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

public struct TableViewCellTextModel: TableViewCellModel {
    public let title: String
    public init(title: String) {
        self.title = title
    }
}


public protocol TableViewChildViewControllerCell {
    var childViewController: UIViewController { get }
}


public class TableView: UITableView {
    public var state: State
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        state = .Loading
        super.init(frame: frame, style: style)
        configure()
    }
    
    public required init(coder aDecoder: NSCoder) {
        state = .Loading
        super.init(coder: aDecoder)
        configure()
    }
    
    public enum State {
        case Loading // Initial loading state. Pull to refresh header will not show.
        case Loaded /// Normal state. Nothing is currently loading.
        case Refreshing /// Refreshing after a pull-to-refresh. The refreshHeaderView will be showing.
        case Errored /// Network request errored.
    }
    
    func configure() {
        // Make sure you set estimated row height, or UITableViewAutomaticDimension won't work.
        estimatedRowHeight = 44.0
    }
    
}


public class TableViewCell: UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        // this prevents the temporary unsatisfiable constraint state that the cell's contentView could
        // enter since it starts off 44pts tall
        self.contentView.autoresizingMask |= .FlexibleHeight;
    }
    
    public func setModel(model: TableViewCellModel) {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
}

public class TableViewDataSource: NSObject {
    
    /// Set as the parent view controller of any cells implementing TableViewChildViewControllerCell.
    public weak var parentViewController: UIViewController?
    
    
    //MARK: Configuration
    
    public func tableView(tableView: UITableView, configureCell cell: TableViewCell, forIndexPath indexPath: NSIndexPath) {
        cell.setModel(self.tableView(tableView, modelForIndexPath: indexPath))
    }
    
    //MARK: Reuse Identifiers
    
    public func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    //MARK: Models
    
    public func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
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