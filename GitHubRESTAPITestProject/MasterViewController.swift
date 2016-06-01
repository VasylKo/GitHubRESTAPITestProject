//
//  MasterViewController.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import PINRemoteImage
import SafariServices

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    private var gists = [Gist]()
    private var nextPageURLString: String?
    private var isLoading = false
    private lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        return dateFormatter
    }()
    private var safariViewController: SFSafariViewController?
    private let oAuth2Manager: OAuth2Manager
    private let gitHubAPIManager: GitHubAPIManager
    
    required init?(coder aDecoder: NSCoder) {
        oAuth2Manager = OAuth2Manager.sharedInstance
        gitHubAPIManager = GitHubAPIManager.sharedInstance
        super.init(coder: aDecoder)
    }
    
    //MARK: -View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        //add refresh controll
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: .ValueChanged)
            refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Load lists of gists
        //loadGists()
        
        //Auth 2.0 flow
        loadInitialData()
    }
    
    //MARK: - View Logic
    func showOAuthLoginView() {
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            loginVC.delegate = self
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Refresh controll
    func refresh(sender: AnyObject) {
        nextPageURLString = nil
        loadGists()
    }
    
    //MARK: - Network Call
    private func loadInitialData() {
        switch OAuth2Manager.sharedInstance.oAuthStatus {
        case .NotAuthorised:
            showOAuthLoginView()
        case .HasToken(_):
            gitHubAPIManager.printMyStarredGistsWithOAuth2()
        default:
            break
        }
    }
    
    ///Load list of Gists from GitHub.
    ///- Parameter urlToLoad: optional specify the URL to load gists (used for pagination).
    private func loadGists(urlToLoad: String? = nil) {
        self.isLoading = true
        gitHubAPIManager.getPublicGists(urlToLoad) {
            (result, nextPage) in
            self.isLoading = false
            self.nextPageURLString = nextPage
            
            //Hide refresh controll
            if self.refreshControl != nil && self.refreshControl!.refreshing {
                self.refreshControl!.endRefreshing()
            }
            
            guard result.error == nil else {
                print(result.error)
                // TODO: display error
                return
            }
            
            if let fetchedGists = result.value {
                if urlToLoad != nil {
                    self.gists += fetchedGists
                } else {
                    self.gists = fetchedGists
                }
            }
            
            // update "last updated" title for refresh control
            let now = NSDate()
            let updateString = "Last Updated at " + self.dateFormatter.stringFromDate(now)
            self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
            
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Actions
    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Not Implemented", message: "Can't create new gists yet, will implement later", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[indexPath.row] as Gist
                if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
                    detailViewController.detailItem = gist
                    detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    detailViewController.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let gist = gists[indexPath.row]
        cell.textLabel!.text = gist.description
        cell.detailTextLabel!.text = gist.ownerLogin
        cell.imageView?.image = nil
        
        // set cell.imageView to display image at gist.ownerAvatarURL
        if let urlString = gist.ownerAvatarURL, url = NSURL(string: urlString) {
            cell.imageView?.pin_setImageFromURL(url, placeholderImage:
                UIImage(named: "placeholder.png"))
        } else {
            cell.imageView?.image = UIImage(named: "placeholder.png")
        }
        
        // See if we need to load more gists
        let rowsToLoadFromBottom = 5
        let rowsLoaded = gists.count
        if let nextPage = nextPageURLString {
            if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                self.loadGists(nextPage)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            gists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array,
            // and add a new row to the table view.
        }
    }

}

extension MasterViewController: LoginViewDelegate {
    func didTapLoginButton() {
        oAuth2Manager.startAuthorisationProcess()
        dismissViewControllerAnimated(false, completion: nil)
        guard let authURL = OAuth2Manager.sharedInstance.URLToStartOAuth2Login() else  {
            return
        }
        
        safariViewController = SFSafariViewController(URL: authURL)
        safariViewController?.delegate = self
        presentViewController(safariViewController!, animated: true, completion: nil)
        
    }
}

// MARK: - Safari View Controller Delegate
extension MasterViewController: SFSafariViewControllerDelegate {
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        // Detect not being able to load the OAuth URL
        guard didLoadSuccessfully else {
            oAuth2Manager.authorisationProcessFail()
            controller.dismissViewControllerAnimated(true, completion: nil)
            return
        }
    }
    
    //In case user close safari VC
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        oAuth2Manager.authorisationProcessFail()
    }
}

