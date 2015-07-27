//
//  ProductDetailsViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 27/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class ProductDetailsViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateItemsWidth(view.bounds.width)
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateItemsWidth(size.width)

    }
    
    private func updateItemsWidth(width: CGFloat) {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: width, height: layout.itemSize.height)
            layout.invalidateLayout()
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0,1:
            return 1
        case 2:
            return 30
        default:
            fatalError("Unknown section")
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: 0, height: 100.0)
        case 2:
            return CGSize(width: 0, height: 50.0)
        default:
            return CGSizeZero
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.dequeueReusableCell(ProductDetailsViewController.Reusable.ProductInfo, forIndexPath: indexPath) {
                return cell
            }
        case 1,2:
            if let cell = collectionView.dequeueReusableCell(ProductDetailsViewController.Reusable.ProductAction, forIndexPath: indexPath) {
                return cell
            }
        default:
            break
        }
        fatalError("Unknown indexPath")
    }
    

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && indexPath.row == 0 {
            let reusable = ProductDetailsViewController.Reusable.ProductDetailsHeader
            if let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReusable: reusable, forIndexPath: indexPath)  {
//                header.backImage =
                return header
            }
        }
        return UICollectionReusableView()
    }


}

class ProductDetailsHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var backImage: UIImageView!
}

class ProductActionCell: UICollectionViewCell {
    
}

class ProductInfoCell: UICollectionViewCell {
    
}


