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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupU()
        prepareTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeFooterView()
    }
    
    // MARK: - UI Setup
    func sizeFooterView() {
        guard let tableView = tableView, footerView = tableView.tableFooterView else { return }
        
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        
        let height = footerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height
        footerView.frame = frame
        
        tableView.tableFooterView = footerView
    }
    
    
    private func setupU() {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
                                                                  style: .Plain, target: self, action: #selector(IntroPageViewController.giveBloodPressed))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func prepareTableView() {
        tableView?.separatorStyle = .None
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        var nib = UINib(nibName: String(TopIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(TopIntroCell.self))
        
        nib = UINib(nibName: String(MiddleIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(MiddleIntroCell.self))
        
        nib = UINib(nibName: String(BottomIntroCell.self), bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: String(BottomIntroCell.self))
        
        let footerView = NSBundle.mainBundle().loadNibNamed(String(IntroPageFooterView.self), owner: nil, options: nil).first
        if let footerView = footerView as? IntroPageFooterView {
            footerView.delegate = self
            tableView?.tableFooterView = footerView
        }
    }
    
    // MARK: - Actions
    @IBAction func giveBloodPressed() {
        //TODO: add implementation
        print("Give Blood pressed")
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if expandedIndexPaths.contains(indexPath) {
            return 600
        } else {
            return 250
        }
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

// MARK: - IntroPageTableViewFooterViewDelegate
extension IntroPageViewController: IntroPageTableViewFooterViewDelegate {
    func giveBloodButtonPressed() {
        giveBloodPressed()
    }
    
    func skipThisStepButtonPressed() {
        //TODO: add implementation
        print("SkipThisStepButtonPressed")
    }

}

