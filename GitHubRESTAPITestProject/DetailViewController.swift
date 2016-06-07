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
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        tableView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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
        //User can select only files section
        guard let sectionType = SectionType(rawValue: indexPath.section) else { fatalError("Unknow section. Update SectionType enum") }
        switch sectionType {
        case .aboutSection:
            return nil
        case .filesSection:
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
            return 2
        case .filesSection:
            return gist?.files?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        guard let sectionType = SectionType(rawValue: indexPath.section) else { fatalError("Unknow section. Update SectionType enum") }
        
        switch (sectionType, indexPath.row) {
        case (.aboutSection, _):
            //User can select only files section
            cell.selectionStyle = .None
            fallthrough
        case (.aboutSection, 0):
            cell.textLabel?.text = gist?.description
        case (.aboutSection, 1):
            cell.textLabel?.text = gist?.ownerLogin
        case (.filesSection, _):
            if let file = gist?.files?[indexPath.row] {
                cell.textLabel?.text = file.filename
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionType(rawValue: section) else { fatalError("Unknow section. Update SectionType enum") }
        return sectionType.sectionTitle()
    }
}

