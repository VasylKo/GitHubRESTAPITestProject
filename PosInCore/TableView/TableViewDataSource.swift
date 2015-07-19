//
//  TableViewDataSource.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

public class TableViewDataSource: NSObject {
    
    /// Set as the parent view controller of any cells implementing TableViewChildViewControllerCell.
    public weak var parentViewController: UIViewController?
    
    
    //MARK: Configuration
    
    public func tableView(tableView: UITableView, configureCell cell: TableViewCell, forIndexPath indexPath: NSIndexPath) {
        cell.setModel(self.tableView(tableView, modelForIndexPath: indexPath))
    }
    
    public func tableView(tableView: UITableView, configureHeader header: TableViewSectionHeaderFooterView, forSection section: Int) {
        header.position = (0 == section) ? .FirstHeader : .Header
    }
    
    public func tableView(tableView: UITableView, configureFooter footer: TableViewSectionHeaderFooterView, forSection section: Int) {
        footer.position = (tableView.numberOfSections() - 1 == section) ? .LastFooter : .Footer
    }
    
    
    //MARK: Reuse Identifiers
    
    @objc public func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    @objc public func tableView(tableView: UITableView, reuseIdentifierForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    @objc public func tableView(tableView: UITableView, reuseIdentifierForFooterInSection section: Int) -> String? {
        return nil
    }
    
    //MARK: Models
    
    public func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        fatalError("\(self.dynamicType): You must override \(__FUNCTION__)")
    }
    
    //MARK: register views
    
    @objc public func configureTable(tableView: UITableView) {
        for reuseId in nibCellsId() {
            tableView.registerNib(UINib(nibName: reuseId, bundle: nil), forCellReuseIdentifier: reuseId)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    public func nibCellsId() -> [String] {
        return []
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
    
    @objc public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let reuseID = self.tableView(tableView, reuseIdentifierForHeaderInSection: section),
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseID) as? TableViewSectionHeaderFooterView {
                self.tableView(tableView, configureHeader: header, forSection: section)
                return header
        }
        return nil
    }
    
    @objc public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let reuseID = self.tableView(tableView, reuseIdentifierForFooterInSection: section),
            let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseID) as? TableViewSectionHeaderFooterView {
                self.tableView(tableView, configureFooter: footer, forSection: section)
                return footer
        }
        return nil
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
    
    @objc public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

//MARK: ChildViewController support
extension TableViewDataSource {
    @objc public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.conformsToProtocol(TableViewChildViewControllerCell) {
            if let parentController = parentViewController {
                let viewControllerCell = cell as! TableViewChildViewControllerCell
                let childController = viewControllerCell.childViewController
                childController.willMoveToParentViewController(parentController)
                parentController.addChildViewController(childController)
                childController.didMoveToParentViewController(parentController)
            } else {
                fatalError("Must have a parent view controller to support cell \(cell)")
            }
        }
    }
    
    @objc public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.conformsToProtocol(TableViewChildViewControllerCell) {
            if let parentController = parentViewController {
                let viewControllerCell = cell as! TableViewChildViewControllerCell
                let childController = viewControllerCell.childViewController
                childController.willMoveToParentViewController(nil)
                childController.removeFromParentViewController()
            } else {
                fatalError("Must have a parent view controller to support cell \(cell)")
            }
        }
    }
    
}


//MARK: UIScrollViewDelegate
extension TableViewDataSource {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if let tableView = scrollView as? TableView {
            tableView.refreshHeaderView?.containingScrollViewDidScroll(tableView)
        } else {
            fatalError("his can only be the delegate of a TableView")
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let tableView = scrollView as? TableView {
            tableView.refreshHeaderView?.containingScrollViewDidEndDragging(tableView)
        } else {
            fatalError("his can only be the delegate of a TableView")
        }
    }
}