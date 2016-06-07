//
//  DetailViewController.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    private var isStarred: Bool?
    
    private enum SectionType: Int {
        case aboutSection = 0
        case filesSection
        
        static func numberOfSections() -> Int {
            return 2
        }
        
        func sectionTitle() -> String {
            switch self {
            case .aboutSection:
                return "About"
            case .filesSection:
                return "Files (click to open)"
            }
        }
    }

    var gist: Gist? {
        didSet {
            if gist != nil {
                fetchStarredStatus()
            }
            configureView()
        }
    }

// MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
// MARK: - UI
    func configureView() {
        tableView?.reloadData()
    }
    
    private func showStarredStatusError(error: NSError) {
        let alertController = UIAlertController(title: "Could not get starred status", message: error.description, preferredStyle: .Alert)
        // add ok button
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated:true, completion: nil)
    }
    
    private func addStarredTableViewRow() {
        let section = SectionType.aboutSection.rawValue
        let indexPathToInsert = NSIndexPath(forRow: 2, inSection: section)
        tableView?.insertRowsAtIndexPaths([indexPathToInsert], withRowAnimation: .Automatic)
    }
    
// MARK: - Stars
    func fetchStarredStatus() {
        guard let gistId = gist?.id else { return }
        GitHubAPIManager.sharedInstance.isGistStarred(gistId, completionHandler: { [weak self] result in
            guard let strongSelf = self else { return }
            
            guard result.error == nil else {
                let error = result.error!
                print("ERROR: \(error.localizedDescription)")
                if error.code == NSURLErrorUserAuthenticationRequired {
                    strongSelf.showStarredStatusError(error)
                }
                return
            }
            
            guard let isStarred = result.value else { return }
                strongSelf.isStarred = isStarred
                strongSelf.addStarredTableViewRow()
        })
        
    }
    
}

//MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard indexPath.section == 1, let file = gist?.files?[indexPath.row],
            urlString = file.raw_url, url = NSURL(string: urlString)  else { return }
        
        let safariViewController = SFSafariViewController(URL: url)
        safariViewController.title = file.filename
        navigationController?.pushViewController(safariViewController, animated: true)
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //User can't select 1,2 row in first section
        guard let sectionType = SectionType(rawValue: indexPath.section) else { fatalError("Unknow section. Update SectionType enum") }
        switch (sectionType, indexPath.row)  {
        case (.aboutSection, 0..<2):
            return nil
        default:
            return indexPath
        }
    }
}

//MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SectionType.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else { fatalError("Unknow section. Update SectionType enum") }
        switch sectionType {
        case .aboutSection:
            return isStarred != nil ? 3 : 2
        case .filesSection:
            return gist?.files?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        
        guard let sectionType = SectionType(rawValue: indexPath.section) else { fatalError("Unknow section. Update SectionType enum") }
        
        switch (sectionType, indexPath.row) {
        case (.aboutSection, 0):
            cell = tableView.dequeueReusableCellWithIdentifier("aboutCell", forIndexPath: indexPath)
            guard let cell = cell as? AboutGistCell else { fatalError("check cell type") }
            cell.selectionStyle = .None
            cell.titleLabel?.text = "Gist description"
            cell.descriptionLabel?.text = gist?.description
        case (.aboutSection, 1):
            cell = tableView.dequeueReusableCellWithIdentifier("aboutCell", forIndexPath: indexPath)
            guard let cell = cell as? AboutGistCell else { fatalError("check cell type") }
            cell.selectionStyle = .None
            cell.titleLabel?.text = "Gist owner"
            cell.descriptionLabel?.text = gist?.ownerLogin
        case (.aboutSection, 2):
            cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath)
            guard let isStarred = isStarred else { break }
            cell.textLabel?.text = isStarred ? "Unstar" : "Star"
            cell.imageView?.image = UIImage(named: "star")
        case (.filesSection, _):
            cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath)
            if let file = gist?.files?[indexPath.row] {
                cell.textLabel?.text = file.filename
            }
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionType(rawValue: section) else { fatalError("Unknow section. Update SectionType enum") }
        return sectionType.sectionTitle()
    }
}

