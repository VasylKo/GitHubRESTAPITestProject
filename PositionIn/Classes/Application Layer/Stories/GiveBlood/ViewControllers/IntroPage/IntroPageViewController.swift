//
//  TestIntroPageViewController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/6/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class IntroPageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    private let router : GiveBloodRouter
    private var expandedIndexPaths = [NSIndexPath]()
    
    private enum GiveBloodCellType: Int {
        case TopCell = 0, MiddleCell, BottomCell
    }
    
    // MARK: - Init
    init(router: GiveBloodRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(IntroPageViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.separatorStyle = .None
        
        var nib = UINib(nibName: String(TopIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(TopIntroCell.self))
        
        nib = UINib(nibName: String(MiddleIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(MiddleIntroCell.self))
        
        nib = UINib(nibName: String(BottomIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(BottomIntroCell.self))
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 50;
        
    }

}

// MARK: - Table view data source
extension IntroPageViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = GiveBloodCellType(rawValue: indexPath.section) else {
            fatalError("Cell type don't found")
        }
        
        let cell: UITableViewCell
        
        switch cellType {
        case .TopCell:
            cell = tableView.dequeueReusableCellWithIdentifier(String(TopIntroCell.self), forIndexPath: indexPath)
        case .MiddleCell:
            cell = tableView.dequeueReusableCellWithIdentifier(String(MiddleIntroCell.self), forIndexPath: indexPath)
        case .BottomCell:
            cell = tableView.dequeueReusableCellWithIdentifier(String(BottomIntroCell.self), forIndexPath: indexPath)
        }
        
        if let cell = cell as? GiveBloodIntroCell {
            cell.showMore = expandedIndexPaths.contains(indexPath)
            cell.delegate = self
        }
        
        return cell
    }
    
}

// MARK: - Table view delegate
extension IntroPageViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: - GiveBloodIntroCellDelegate
extension IntroPageViewController: GiveBloodIntroCellDelegate {
    func readMoreButtonPressedOnCell(cell: UITableViewCell) {
        guard let indexPath = tableView?.indexPathForCell(cell) else { return }
        expandedIndexPaths.append(indexPath)
        
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
}

