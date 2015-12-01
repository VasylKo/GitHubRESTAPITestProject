//
//  BrowseGridViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

protocol BrowseGridViewControllerDelegate : class {
    func browseGridViewControllerSelectItem(itemType: HomeItem)
}

class BrowseGridViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let reuseIdentifier = NSStringFromClass(BrowseGridCollectionViewCell.self)
        self.collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(96, 96)
        flowLayout.minimumInteritemSpacing = 8
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
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