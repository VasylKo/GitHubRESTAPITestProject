//
//  ProductInventoryViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 31/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class ProductInventoryViewController: UIViewController {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://pbs.twimg.com/profile_images/3255786215/509fd5bc902d71141990920bf207edea.jpeg")!
        avatarView.setImageFromURL(url)
        let reuseId = NSStringFromClass(ProductInventoryCell)
        collectionView.registerNib(UINib(nibName: reuseId, bundle: nil), forCellWithReuseIdentifier: reuseId)
        updateItemsWidth(view.bounds.width)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateItemsWidth(size.width)
    }
    
    private func updateItemsWidth(width: CGFloat) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width / 2.0, height: layout.itemSize.height)
    }
    
}


extension ProductInventoryViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseId = NSStringFromClass(ProductInventoryCell)
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as? ProductInventoryCell {
            return cell
        }
        return UICollectionViewCell()
    }

}


extension ProductInventoryViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        performSegue(ProductInventoryViewController.Segue.ShowProductDetails)
    }

}
