//
//  BrowseGridViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

protocol BrowseGridViewControllerDelegate : class {
    func browseGridViewControllerSelectItem(homeItem: HomeItem)
}

class BrowseGridViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let reuseIdentifier = NSStringFromClass(BrowseGridCollectionViewCell.self)
        self.collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        //different ui sizes for 6, 6+
        if (UIScreen.mainScreen().bounds.size.height > 568) {
            flowLayout.itemSize = CGSizeMake(117, 117)
            flowLayout.minimumInteritemSpacing = 6
        }
        else {
            flowLayout.itemSize = CGSizeMake(96, 96)
            flowLayout.minimumInteritemSpacing = 8
        }        
        
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
        
        setNavigationButtons()
    }
    
    
    private func setNavigationButtons() {
        //Call parent view controller with navigation bar (BrowseMainGridController) where we whant to add notification button
        let notificationBarButtonItem = UIBarButtonItem(image: UIImage(named: "notification_icon"), style: .Plain, target: self, action: "notificationTouched")
        parentViewController?.navigationItem.rightBarButtonItem = notificationBarButtonItem
        parentViewController?.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        api().hasNotifications().onSuccess { [weak self] (has : Bool) -> Void in
            self?.parentViewController?.navigationItem.rightBarButtonItem?.enabled = has
        }
        trackScreenToAnalytics(AnalyticsLabels.home)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let container = NotificationViewContainer(frame: CGRectZero)
        container.show()
        
    }
    
    @objc func notificationTouched() {
        let controller = NotificationViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    weak var browseGridDelegate: BrowseGridViewControllerDelegate?
    @IBOutlet private weak var collectionView: UICollectionView!
}


extension BrowseGridViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let homeItem = HomeItem.homeItemForUI(indexPath.row)
        self.browseGridDelegate?.browseGridViewControllerSelectItem(homeItem)
    }
}

extension BrowseGridViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeItem.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(BrowseGridCollectionViewCell.self), forIndexPath: indexPath)
        if let cell = cell as? BrowseGridCollectionViewCell {
            
            let homeItem = HomeItem.homeItemForUI(indexPath.row)
            cell.name = homeItem.displayString()
            cell.image = homeItem.image()
        }
        return cell
    }
}