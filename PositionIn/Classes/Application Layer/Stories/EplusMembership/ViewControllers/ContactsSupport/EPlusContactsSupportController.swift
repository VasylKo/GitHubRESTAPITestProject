//
//  EPlusContactsSupportController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusContactsSupportController: UIViewController {
    typealias Section = [String : AnyObject]
    typealias Cell = [String : AnyObject]
    
    // MARK: - Constants
    private let sectionTitleKey = "section"
    private let dataKey = "data"
    private let actionKey = "action"
    private let textKey = "text"
    private let imageNameKey = "image"
    
    private let section1Title = NSLocalizedString("TOLL FREE NO.")
    private let phone1Sec1 = "1199"
    
    private let section2Title = NSLocalizedString("EMERGENCY NUMBERS")
    private let phone1Sec2 = "0700 395 395"
    private let phone2Sec2 = "0738 395 395"
    
    private let section3Title = NSLocalizedString("OFFICE CELL")
    private let phone1Sec3 = "+254 717 714938"
 
    private let section4Title = NSLocalizedString("OFFICE NUMBERS")
    private let phone1Sec4 = "+254 20 2655250"
    private let phone2Sec4 = "+254 20 2655251"
    private let phone3Sec4 = "+254 20 2655252"
    private let phone4Sec4 = "+254 20 2655253"
    
    private let section5Title = ""
    private let text1Sec5 = "info@eplus.co.ke"
    private let picForText1Sec5 = "email_icon"
    private let text2Sec5 = "www.eplus.co.ke"
    private let picForText2Sec5 = "website_icon"

    
    
    private enum Actions: String {
        case Tel = "tel"
        case Link = "http://www.eplus.co.ke"
        case Email = "info@eplus.co.ke"
    }

    private var dataStore = [Section]()
    private let router : EPlusMembershipRouter
    @IBOutlet weak var tableView: UITableView?
    
    // MARK: - Inits
    init(router: EPlusMembershipRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(EPlusContactsSupportController.self), bundle: nil)
        
        populateMockData()
        
        print("Mock data")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Contact Support")
    }



    // MARK: - Private implementation
    private func executeAction(action: Actions, forCell cell: Cell) {
        switch action {
        case .Tel:
            if let tel = cell[textKey] as? String  {
                OpenApplication.Tel(with: tel.stringByReplacingOccurrencesOfString(" ", withString: ""))
            }
            
        case .Link:
            let url = NSURL(string: action.rawValue)!
            OpenApplication.Safari(with: url)

        case .Email:
            MailComposeViewController.presentMailControllerFrom(self, recipientsList: [action.rawValue])
        }
    }
}

// MARK: - Mock data extension
extension EPlusContactsSupportController {
    
    private func populateMockData() {
        //Configure section
        var section = sectionWithTitle(section1Title)
        
        var cell = cellWithTitle(phone1Sec1, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        dataStore.append(section)
        
        //Configure section
        section = sectionWithTitle(section2Title)
        
        cell = cellWithTitle(phone1Sec2, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        cell = cellWithTitle(phone2Sec2, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        dataStore.append(section)
        
        //Configure section
        section = sectionWithTitle(section3Title)
        
        cell = cellWithTitle(phone1Sec3, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        dataStore.append(section)
        
        
        
        //Configure section
        section = sectionWithTitle(section4Title)
        
        cell = cellWithTitle(phone1Sec4, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        cell = cellWithTitle(phone2Sec4, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        cell = cellWithTitle(phone3Sec4, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        cell = cellWithTitle(phone4Sec4, image: nil, action: Actions.Tel)
        addCell(cell, toSection: &section)
        
        dataStore.append(section)
        
        //Configure section
        section = sectionWithTitle(section5Title)
        
        cell = cellWithTitle(text1Sec5, image: picForText1Sec5, action: Actions.Email)
        addCell(cell, toSection: &section)
            
        cell = cellWithTitle(text2Sec5, image: picForText2Sec5, action: Actions.Link)
        addCell(cell, toSection: &section)
        
        dataStore.append(section)
        
    }
    
    private func sectionWithTitle(title: String) -> Section {
        let section: Section = [    sectionTitleKey : title,
            dataKey         : [Cell]() ]
        
        
        return section
    }
    
    private func cellWithTitle(title: String, image: String?, action: Actions) -> Cell {
        
        var cell: Cell = [  textKey     : title,
            actionKey   :  action.rawValue]
        if let image = image {
            cell[imageNameKey] = image
        }
        
        return cell
    }
    
    private func addCell(cell: Cell, inout toSection section: Section)
    {
        
        if var dataArray = section[dataKey] as? [AnyObject] {
            dataArray.append(cell)
            section[dataKey] = dataArray
        }
    }
    
    private func titleForSection(section: Section) -> String {
        let title = section[sectionTitleKey] as? String
        return title ?? ""
    }
}

    // MARK: - Table view data source
extension EPlusContactsSupportController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataStore.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section_obj = dataStore[section]
        let dataArray = section_obj[dataKey] as? [AnyObject]
        
        return dataArray?.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = dataStore[section]
        let title = section[sectionTitleKey] as? String
        return title
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cellForTableView(tableView)
        
        // Configure the cell
        if let cellInfo = cellInfoForIndePath(indexPath) {
            configureCell(cell, withCellInfo: cellInfo)
        }
        
        return cell
    }
    
    // MARK: - Helper fot table cell
    private func cellForTableView(tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            cell.imageView?.image = nil
            cell.textLabel?.text = nil
            return cell
        } else {
            return UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            
        }
    }
    
    private func configureCell(tableCell: UITableViewCell, withCellInfo cellInfo: Cell) {
        
        if let text = cellInfo[textKey] as? String {
            tableCell.textLabel?.text = text
        }
        
        if let imageName = cellInfo[imageNameKey] as? String, image = UIImage(named: imageName) {
            tableCell.imageView?.image = image
        }
    }
    
    private func cellInfoForIndePath(indexPath: NSIndexPath) -> Cell? {
        let section = dataStore[indexPath.section]
        if let cells = section[dataKey], cellInfo = cells[indexPath.row] as? Cell {
            return cellInfo
        }
        
        return nil
    }
    
}

// MARK: - Table view delegate
extension EPlusContactsSupportController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIScheme.tableSectionTitleFont
            headerView.textLabel?.textColor = UIScheme.tableSectionTitleColor
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cellInfo = cellInfoForIndePath(indexPath), actionName = cellInfo[actionKey] as? String, action = Actions(rawValue: actionName) {
            executeAction(action, forCell: cellInfo)
        }
    }
}
