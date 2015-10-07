//
//  SearchTransition.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIImageEffects


final class SearchTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    weak var startView: UIView?
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromView = startView {
            let startFrame = fromView.convertRect(fromView.frame, toView: presenting.view)
            let animationController = SearchAppearanceAnimationController(startFrame: startFrame)
            return animationController
        }
        return nil
    }
}

final class SearchAppearanceAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    let transitionDuration: NSTimeInterval = 0.5
    let startFrame: CGRect
    
    override convenience init() {
        self.init(startFrame: CGRectZero)
    }
    
    init(startFrame: CGRect) {
        self.startFrame = startFrame
        super.init()
    }
    
    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
    // synchronize with the main animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return transitionDuration
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let conrainerView = transitionContext.containerView()
        let searchController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! SearchViewController
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        searchController.backImageView.image = snapshotView(fromViewController.view)
        fromViewController.view.removeFromSuperview()
        let searchView = searchController.view
        conrainerView.addSubview(searchView)
        
        let categoriesFrame = searchController.categoriesSearchBar.frame
        searchController.categoriesSearchBar.frame = startFrame
        let locationsFrame = searchController.locationSearchBar.frame
        searchController.locationSearchBar.frame = startFrame
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                searchController.categoriesSearchBar.frame = categoriesFrame
                searchController.locationSearchBar.frame = locationsFrame
            }) { finished in
                transitionContext.completeTransition(finished)
        }
    }
    
//    // This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
//    func animationEnded(transitionCompleted: Bool) {
//
//    }
    
    private func snapshotView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image.applyDarkEffect()
    }
}
