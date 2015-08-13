//
//  CommunityViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class CommunityListViewController: BesideMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        dataSource.configureTable(tableView)
    }

    private lazy var dataSource: CommunityListDataSource = {
        let dataSource = CommunityListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCommunityTouched(sender: AnyObject) {
        navigationController?.pushViewController(Storyboards.NewItems.instantiateAddCommunityViewController(), animated: true)
    }

    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet private weak var tableView: TableView!
}

extension CommunityListViewController {
    internal class CommunityListDataSource: TableViewDataSource {
        
        enum Rows: Int {
            case UserList
            case Body
            case Actions
            
            case CountRows
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 5
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Rows.CountRows.rawValue
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            if let row = Rows(rawValue: indexPath.row) {
                switch row {
                case .UserList:
                    return UserListCell.reuseId()
                case .Body:
                    return CommunityInfoCell.reuseId()
                case .Actions:
                    return CommunityActionCell.reuseId()
                default:
                    break;
                }
            }
            return ""
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            if let row = Rows(rawValue: indexPath.row) {
                switch row {
                case .UserList:
                    let users: [UserProfile] = (1...5).map() { _ in
                        return Mock.userProfile()
                    }
                    return UserListCellModel(users: users)
                default:
                    break;
                }
            }
            return TableViewCellInvalidModel()
        }
        
        override func nibCellsId() -> [String] {
            return [UserListCell.reuseId(),CommunityInfoCell.reuseId(),CommunityActionCell.reuseId()]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)

        }
    }
}