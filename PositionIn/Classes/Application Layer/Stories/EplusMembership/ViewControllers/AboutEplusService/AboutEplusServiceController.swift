//
//  AboutEplusServiceController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class AboutEplusServiceController: UIViewController {

    private enum Section: Int {
        case HeaderView = 0
        case ServicesList = 1
        case ContactUsButton = 2
        case Unknown
        
        static let sectionsCoun = 3
    }
    
    private let cellReuseID = "Cell"
    private let headerReuseID = "TableSectionHeader"
    
    private let router : EPlusMembershipRouter
    @IBOutlet weak var tableView: UITableView?
    private var services: [EPlusService] = []
    
    // MARK: - Inits
    init(router: EPlusMembershipRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(AboutEplusServiceController.self), bundle: nil)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView?.registerNib(UINib(nibName: "AboutEplusServiceTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseID)
        tableView?.registerNib(UINib(nibName: "AboutEplusServiceTableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: headerReuseID)
        self.loadData()
    }
    
        // MARK: - UI setup
    func loadData() {
        api().getEPlusServices().onSuccess(callback: { [weak self] (response : CollectionResponse<EPlusService>) in
            self?.services = response.items
            self?.tableView?.reloadData()
            })
    }
    
    
    // MARK: - UI setup
    private func setupUI() {
        title = NSLocalizedString("About")
        let rightButton = UIBarButtonItem(image: UIImage(named: "services_icon"), style: .Done, target: self, action: Selector("showContactUsController:"))
        navigationItem.setRightBarButtonItem(rightButton, animated: false)
    }
    
    // MARK: - Private implementation
    private func configureContactUsCell(cell: AboutEplusServiceTableViewCell) {
        cell.icon?.image = UIImage(named: "service_5_eplus_icon")
        cell.title?.text = NSLocalizedString("Contact Us")
        cell.subTitle?.text = NSLocalizedString("E-Plus Medical Service")
    }
    
    func showContactUsController(sender: AnyObject?) {
        router.showContactSupportController(from: self)
    }
    
    func showServiceDetails(service: EPlusService) {
        router.showServiceDetailsController(from: self, with: service)
    }
}

    // MARK: - Table view data source
extension AboutEplusServiceController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //First section with header, 2nd - with dynamic services list, 3d - static contact us button
        return Section.sectionsCoun
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section(rawValue: section) ?? Section.Unknown
        
        switch sectionType {
        case .HeaderView:
            return  0
        case .ServicesList:
            return  services.count
        case .ContactUsButton:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseID, forIndexPath: indexPath) as! AboutEplusServiceTableViewCell
        
        let sectionType = Section(rawValue: indexPath.section) ?? Section.Unknown
        
        switch sectionType {
        case .ContactUsButton:
            configureContactUsCell(cell)
        
        case .ServicesList:
            let service = services[indexPath.row]
            cell.icon?.image = UIImage(named: service.serviceImageName)
            cell.title?.text = service.name
            cell.subTitle?.text = service.shortDesc
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section) where sectionType == .HeaderView else { return nil }
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerReuseID)
        return headerView
    }
}

    // MARK: - Table view delegate
extension AboutEplusServiceController: UITableViewDelegate {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) where sectionType == .ServicesList else { return nil }
        return NSLocalizedString("OUR SERVICES")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionType = Section(rawValue: section) where sectionType == .HeaderView {
            return 120.0
        } else {
            return 20
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sectionType = Section(rawValue: indexPath.section) ?? Section.Unknown
        switch sectionType {
        case .ServicesList:
            let service = services[indexPath.row]
            showServiceDetails(service)
            break
        
        case .ContactUsButton:
            showContactUsController(nil)
        
        default:
            break
        }
        
    }
    
}