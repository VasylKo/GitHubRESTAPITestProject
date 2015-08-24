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
            AddMenuView.MenuItem(
                title: NSLocalizedString("PRODUCT",comment: "Add menu: PRODUCT"),
                icon: UIImage(named: "AddProduct")!,
                color: UIScheme.productAddMenuColor,
                action: {[weak self] in
                    self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddProductViewController(), animated: true)
                }
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("EVENT",comment: "Add menu: EVENT"),
                icon: UIImage(named: "AddEvent")!,
                color: UIScheme.eventAddMenuColor,
                action: {[weak self] in
                    self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddEventViewController(), animated: true)
                }
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("PROMOTION",comment: "Add menu: PROMOTION"),
                icon: UIImage(named: "AddPromotion")!,
                color: UIScheme.promotionAddMenuColor,
                action: {[weak self] in
                    self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPromotionViewController(), animated: true)
                }
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("POST",comment: "Add menu: POST"),
                icon: UIImage(named: "AddPost")!,
                color: UIScheme.postAddMenuColor,
                action: {[weak self] in
                    self?.navigationController?.pushViewController(Storyboards.NewItems.instantiateAddPostViewController(), animated: true)
                }
            ),
            AddMenuView.MenuItem(
                title: NSLocalizedString("INVITE",comment: "Add menu: INVITE"),
                icon: UIImage(named: "AddInvite")!,
                color: UIScheme.inviteAddMenuColor,
                action: {[weak self] in
                    Log.debug?.message("Should call invite")
                }
            ),
        ]
    }

    
}


//MARK: Browse actions
//extension BrowseViewController: BrowseActionConsumer {
//    func browseController(controller: BrowseActionProducer, didSelectPost post: Post) {
//        performSegue(BrowseViewController.Segue.ShowProductDetails)
//    }
//}
