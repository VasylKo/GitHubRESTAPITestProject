//
//  TableRefreshHeaderView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

/// //! Abstract class used for refresh header views.  TableView will call those methods automatically. Add a target for the UIControlEventValueChanged event to refresh the table view.

public class TableRefreshHeaderView: UIControl {

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    public var refreshState: State  {
        get {
            return currentState
        }
        set {
            setRefreshState(newValue, animated: true)
        }
    }
    
    public var pullAmountToRefresh: CGFloat {
        fatalError("Abstract method – subclasses must implement \(__FUNCTION__).")
    }
    
    private(set) public var currentPullAmount: CGFloat = 0
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let bottomPadding: CGFloat = 2
        return CGSize(width: size.width, height: pullAmountToRefresh - bottomPadding)
    }
    
    public func setRefreshState(state: State, animated: Bool = true) {
        currentState = state
        let animations: () -> Void = {
            if let scrollView = self.scrollView {
                var contentInset = scrollView.contentInset
                contentInset.top = (state == .Refreshing) ? self.pullAmountToRefresh : 0
                scrollView.contentInset = contentInset
            }
        }
        let completion: Bool -> Void = { _ in
            if self.refreshState == .Closing {
                self.setRefreshState(.Normal)
            }
        }
        
        if (animated) {
            UIView.animateWithDuration(0.2, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
    
    internal(set) public weak var scrollView: UIScrollView?
    
    
    /*
    //! The scroll view that this refresh header is at the top of.
    @property (weak, nonatomic) UIScrollView *scrollView;
    
    //! Called from scrollViewDidScroll: to update the refresh header
    - (void)containingScrollViewDidScroll:(UIScrollView *)scrollView;
    
    //! Called from scrollViewDidEndDragging: to potentially start the refresh
    - (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView;
    
    */
    
    private func configure() {
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        clipsToBounds = true
        refreshState = .Normal
    }
    
    private var currentState: State = .Normal
    
    public enum State {
        case Normal // No refresh is currently happening. The user might have pulled the header down a bit, but not enough to trigger a refresh.
        case ReadyToRefresh // The user has pulled down the header far enough to trigger a refresh, but has not released yet.
        case Refreshing // Refreshing, either after the user pulled to refresh or a refresh was started programmatically.
        case Closing // The refresh has just finished and the refresh header is in the process of closing.
    }
}

//MARK: ScrollViewDelegate
extension TableRefreshHeaderView  {
    
    /**
    Called from scrollViewDidScroll: to update the refresh header
    
    :param: scrollView scroll view
    */
    internal func containingScrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.dragging {
            // If we were ready to refresh but then dragged back up, cancel the Ready to Refresh state.
            if refreshState == .ReadyToRefresh && scrollView.contentOffset.y > -pullAmountToRefresh && scrollView.contentOffset.y < 0 {
                setRefreshState(.Normal)
                // If we've dragged far enough, put us in the Ready to Refresh state
            } else if refreshState == .Normal && scrollView.contentOffset.y <= -pullAmountToRefresh {
                setRefreshState(.ReadyToRefresh)
            }
        }
        currentPullAmount = max(0, -scrollView.contentOffset.y)
    }
    
    /**
    Called from scrollViewDidEndDragging: to potentially start the refresh
    
    :param: scrollView scroll view
    */
    internal func containingScrollViewDidEndDragging(scrollView: UIScrollView) {
        // Trigger the action if it was pulled far enough.
        if scrollView.contentOffset.y <= -pullAmountToRefresh && refreshState != .Refreshing {
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        } else {
            currentPullAmount = 0
        }
    }
}