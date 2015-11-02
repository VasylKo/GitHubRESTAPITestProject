//
//  TableView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

public class TableView: UITableView {
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        state = .Loading
        super.init(frame: frame, style: style)
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        state = .Loading
        super.init(coder: aDecoder)
        configure()
    }
    
    public var refreshHeaderView: TableRefreshHeaderView? {
        set {
            if let oldRefreshHeaderView = refreshHeader {
                oldRefreshHeaderView.removeFromSuperview()
            }
            if let newRefreshHeaderView = newValue {
                addSubview(newRefreshHeaderView)
                sendSubviewToBack(newRefreshHeaderView)
                showsVerticalScrollIndicator = true
                newRefreshHeaderView.scrollView = self
            }
            refreshHeader = newValue
        }
        get {
            return refreshHeader
        }
    }
    
    public var state: State {
        willSet {
            var refreshState: TableRefreshHeaderView.State = .Normal
            if state == .Refreshing {
                refreshState = .Refreshing
            } else if let refreshHeader = refreshHeaderView where refreshHeader.refreshState == .Refreshing {
                refreshState = .Closing
            }
            refreshHeader?.refreshState = refreshState
        }
    }
    
    public enum State {
        case Loading // Initial loading state. Pull to refresh header will not show.
        case Loaded /// Normal state. Nothing is currently loading.
        case Refreshing /// Refreshing after a pull-to-refresh. The refreshHeaderView will be showing.
        case Errored /// Network request errored.
    }
    
    private func configure() {
        // Make sure you set estimated row height, or UITableViewAutomaticDimension won't work.
        estimatedRowHeight = 44.0
    }
    
    private var refreshHeader: TableRefreshHeaderView?
    
    //MARK: RefreshHeaderView
    public override func layoutSubviews() {
        super.layoutSubviews()
    
    // Put self.refreshHeaderView above the origin of self.frame. We set self.refreshHeaderView.frame.size to be equal to self.frame.size to gurantee that you won't be able to see beyond the top of the header view.
    // self.refreshHeaderView should draw it's content at the bottom of its frame.
        refreshHeader?.frame = CGRect(x: 0, y: -bounds.height, width: bounds.size.width, height: bounds.size.height)
    }
  
}
