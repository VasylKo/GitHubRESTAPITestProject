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
        case ServicesList = 0
        case ContactUsButton = 1
        case Unknown
        
        static let sectionsCoun = 2
    }
    
    private let cellReuseID = "Cell"
    private var isLoadingData = true
    private var data: CollectionResponse<EPlusService>?
    private let router : EPlusMembershipRouter
    @IBOutlet weak var tableView: UITableView?
    
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

        //Add table view header
        if let headerView = NSBundle.mainBundle().loadNibNamed(String(AboutEplusServiceTableViewHeaderView.self), owner: nil, options: nil).first as? UIView {
            tableView?.tableHeaderView = headerView
        }
        
        getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    
    // MARK: - UI setup
    private func setupUI() {
        title = NSLocalizedString("About")
        let rightButton = UIBarButtonItem(image: UIImage(named: "services_icon"), style: .Done, target: self, action: Selector("showContactUsController:"))
        navigationItem.setRightBarButtonItem(rightButton, animated: false)
    }
    
    private func sizeHeaderToFit() {
        guard let headerView = tableView?.tableHeaderView else { return }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView!.tableHeaderView = headerView
    }
    
    // MARK: - Private implementation
    private func getData() {
        api().getEPlusServices().onSuccess { [weak self] (plans: CollectionResponse<EPlusService>) -> Void in
            if plans.total > 0 {
                self?.data = plans
            }
            
        }.onComplete {[weak self] _ in
            self?.isLoadingData = false
            self?.tableView?.reloadData()
        }
    }
    
    private func configureContactUsCell(cell: AboutEplusServiceTableViewCell) {
        let image = UIImage(named: "service_5_eplus_icon")
        let title = NSLocalizedString("Contact Us")
        let subTitle = NSLocalizedString("E-Plus Medical Service")
        cell.configureCellWith(title, subTitle: subTitle, image: image)
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIScheme.tableSectionTitleFont
            headerView.textLabel?.textColor = UIScheme.tableSectionTitleColor
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //First section with header, 2nd - with dynamic services list, 3d - static contact us button
        return Section.sectionsCoun
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section(rawValue: section) ?? Section.Unknown
        
        switch sectionType {
        case .ServicesList where isLoadingData:
           //Row with spiner
            return 1
            
        case .ServicesList:
            return self.data?.total ?? 0

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
            if !isLoadingData, let service = data?.items[indexPath.row] {
                let image = UIImage(named: service.serviceImageName)
                let title = service.name
                let subTitle = service.shortDesc
                cell.configureCellWith(title, subTitle: subTitle, image: image)
            }
        
        default:
            break
        }
        
        return cell
    }
    
}

    // MARK: - Table view delegate
extension AboutEplusServiceController: UITableViewDelegate {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) where sectionType == .ServicesList else { return nil }
        return NSLocalizedString("OUR SERVICES")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sectionType = Section(rawValue: indexPath.section) ?? Section.Unknown
        
        switch sectionType {
        case .ServicesList:
            let service = data?.items[indexPath.row]
            if let service = service {
                showServiceDetails(service)
            }
            break
        case .ContactUsButton:
            showContactUsController(nil)
        
        default:
            break
        }
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //Cant press on loading cell
        if let sectionType = Section(rawValue: indexPath.section) where sectionType == .ServicesList && isLoadingData {
            return nil
        } else {
            return indexPath
        }
    }
    
}