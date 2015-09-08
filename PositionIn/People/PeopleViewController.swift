//
//  PeopleViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 08/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger


final class PeopleViewController: BesideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseMode = .Following

    }
    
    var browseMode: BrowseMode = .Following {
        didSet {
            browseModeSegmentedControl.selectedSegmentIndex = browseMode.rawValue
            reloadData()
        }
    }
    
    enum BrowseMode: Int {
        case Following
        case Explore
    }
    
    func reloadData() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
    }

    
    override func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        if isViewLoaded() {
            reloadData()
        }
    }

    @IBAction func browseModeSegmentChanged(sender: UISegmentedControl) {
        if let mode = BrowseMode(rawValue: sender.selectedSegmentIndex) {
            browseMode = mode
        }
    }
    
    @IBOutlet private weak var browseModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var tableView: TableView!
    
    private var dataRequestToken = InvalidationToken()

}
