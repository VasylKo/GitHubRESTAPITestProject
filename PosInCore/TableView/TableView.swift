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
    
    public required init(coder aDecoder: NSCoder) {
        state = .Loading
        super.init(coder: aDecoder)
        configure()
    }
    
    public var state: State
    
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
    
    //MARK: RefreshHeaderView
    public override func layoutSubviews() {
        super.layoutSubviews()
    
    // Put self.refreshHeaderView above the origin of self.frame. We set self.refreshHeaderView.frame.size to be equal to self.frame.size to gurantee that you won't be able to see beyond the top of the header view.
    // self.refreshHeaderView should draw it's content at the bottom of its frame.
//    self.refreshHeaderView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
/*
    - (void)setRefreshHeaderView:(YLRefreshHeaderView *)refreshHeaderView {
    if (refreshHeaderView) {
    [self addSubview:refreshHeaderView];
    [self sendSubviewToBack:refreshHeaderView];
    self.showsVerticalScrollIndicator = YES;
    refreshHeaderView.scrollView = self;
    } else {
    [self.refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = refreshHeaderView;
    }
    
    #pragma mark State

    - (void)setState:(YLTableViewState)state {
    YLRefreshHeaderViewState newState = YLRefreshHeaderViewStateNormal;
    if (state == YLTableViewStateRefreshing) {
    newState = YLRefreshHeaderViewStateRefreshing;
    } else if (self.refreshHeaderView.refreshState == YLRefreshHeaderViewStateRefreshing) {
    newState = YLRefreshHeaderViewStateClosing;
    }
    self.refreshHeaderView.refreshState = newState;
    
    _state = state;
    }
*/
  
}
