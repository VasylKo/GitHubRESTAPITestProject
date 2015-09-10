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
        let peopleRequest: Future<CollectionResponse<UserInfo>,NSError>
        switch browseMode {
        case .Following:
            peopleRequest = api().getMySubscriptions()
        case .Explore:
            peopleRequest = api().getUsers(APIService.Page())
        }
        
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

final class PeopleListDataSource: TableViewDataSource {
    private var items: [[TableViewCellModel]] = []

    
    override func configureTable(tableView: UITableView) {
        tableView.estimatedRowHeight = 60.0
        super.configureTable(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
        return PeopleListCell.reuseId()
    }
    
    override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
        return items[indexPath.section][indexPath.row]
    }
    
    
    override func nibCellsId() -> [String] {
        return [ PeopleListCell.reuseId() ]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
