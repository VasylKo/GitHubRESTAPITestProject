//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

final class BrowseViewController: BrowseModeViewController {
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewControllerForMode(mode: DisplayModeViewController.DisplayMode) -> UIViewController {
        switch self.displayMode {
        case .Map:
            return Storyboards.Main.instantiateBrowseMapViewController()
        case .List:
            return Storyboards.Main.instantiateBrowseListViewController()
        }
    }

    
    override var addMenuItems: [AddMenuView.MenuItem] {
        return [
            AddMenuView.MenuItem.productItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddProductViewController(), animated: true)
            },
            AddMenuView.MenuItem.eventItemWithAction { [weak self] in
                    self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddEventViewController(), animated: true)
            },
            AddMenuView.MenuItem.promotionItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPromotionViewController(), animated: true)
            },
            AddMenuView.MenuItem.postItemWithAction { [weak self] in
                self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPostViewController(), animated: true)
            },
            AddMenuView.MenuItem.inviteItemWithAction { [weak self] in
                    Log.debug?.message("Should call invite")
            },
        ]
    }

    
}


//MARK: Browse actions
//extension BrowseViewController: BrowseActionConsumer {
//    func browseController(controller: BrowseActionProducer, didSelectPost post: Post) {
//        performSegue(BrowseViewController.Segue.ShowProductDetails)
//    }
//}
