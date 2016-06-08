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
import Alamofire

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
    
    private enum SegmenterIndexSections: Int {
        case publicGists = 0
        case starredGists
        case myGists
    }
    
    //MARK: - Outlets
    @IBOutlet weak var gistSegmentedControl: UISegmentedControl!
    
    //MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        oAuth2Manager = OAuth2Manager.sharedInstance
        gitHubAPIManager = GitHubAPIManager.sharedInstance
        super.init(coder: aDecoder)
        oAuth2Manager.delegate = self
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.oAuthTokenRequestResponseReceived(_:)), name: OAuthTokenRequestResponseReceivedNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
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
        loadInitialData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - View Logic
    func showOAuthLoginView() {
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController where presentedViewController == nil {
            loginVC.delegate = self
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Refresh controll
    func refresh(sender: AnyObject) {
        loadInitialData()
    }
    
    //MARK: - Network Call
    ///Load lists of gists if the user is authorized
    private func loadInitialData() {
        switch OAuth2Manager.sharedInstance.oAuthStatus {
        case .notAuthorised:
            showOAuthLoginView()
        case .hasToken(_):
            loadGists()
        default:
            break
        }
    }
    
    ///Load list of Gists from GitHub.
    ///- Parameter urlToLoad: optional specify the URL to load gists (used for pagination).
    private func loadGists(urlToLoad: String? = nil) {
        self.isLoading = true
        let sharedCompletionHandler: (Result<[Gist], NSError>, String?) -> Void = {[weak self] (result, nextPage) in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            strongSelf.nextPageURLString = nextPage
            
            //Hide refresh controll
            if strongSelf.refreshControl != nil && strongSelf.refreshControl!.refreshing {
                strongSelf.refreshControl!.endRefreshing()
            }
            
            guard result.error == nil else {
                print("ERROR: \(result.error?.localizedDescription)")
                if result.error!.code == NSURLErrorUserAuthenticationRequired {
                    strongSelf.oAuth2Manager.authorisationProcessFail(withError: result.error!)
                }
                return
            }
            
            if let fetchedGists = result.value {
                if urlToLoad != nil {
                    strongSelf.gists += fetchedGists
                } else {
                    strongSelf.gists = fetchedGists
                }
            }
            
            // update "last updated" title for refresh control
            let now = NSDate()
            let updateString = "Last Updated at " + strongSelf.dateFormatter.stringFromDate(now)
            strongSelf.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
            
            strongSelf.tableView.reloadData()
        }
        
        guard let selectedSegmentIndex = SegmenterIndexSections(rawValue: gistSegmentedControl.selectedSegmentIndex) else { fatalError("Can't get selected segmented section. Check SegmenterIndexSections enum values") }
        switch  selectedSegmentIndex{
        case .publicGists:
            GitHubAPIManager.sharedInstance.getPublicGists(urlToLoad, completionHandler: sharedCompletionHandler)
        case .starredGists:
            GitHubAPIManager.sharedInstance.getMyStarredGists(urlToLoad, completionHandler: sharedCompletionHandler)
        case .myGists:
            GitHubAPIManager.sharedInstance.getMyGists(urlToLoad, completionHandler: sharedCompletionHandler)
            
        }
    }
    
    
    // MARK: - Actions
    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Not Implemented", message: "Can't create new gists yet, will implement later", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        // only show add button for my gists
        guard let selectedState = SegmenterIndexSections(rawValue: sender.selectedSegmentIndex) else { fatalError("Index not found! Check SegmenterIndexSections Enum") }
        if case .myGists = selectedState {
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        loadGists()
    }
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[indexPath.row] as Gist
                if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
                    detailViewController.gist = gist
                    detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    detailViewController.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    // MARK: - Show alert
    private func showError(title title: String, error: NSError) {
        let alertController = UIAlertController(title: title, message: error.description, preferredStyle: .Alert)
        // add ok button
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated:true, completion: nil)
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
        //Can delete only my gists
        guard let selectedState = SegmenterIndexSections(rawValue: gistSegmentedControl.selectedSegmentIndex) else { fatalError("Index not found! Check SegmenterIndexSections Enum") }
        return selectedState == .myGists
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete gist
            if let id = gists[indexPath.row].id {
                GitHubAPIManager.sharedInstance.deleteGist(id, completionHandler: { [weak self] (error) in
                    guard let strongSelf = self else { return }
                    
                    guard error == nil else {
                        strongSelf.showError(title: "Can't delete gist", error: error!)
                        return
                    }
                    //Delete gist from the table
                    strongSelf.gists.removeAtIndex(indexPath.row)
                    strongSelf.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                })
            }
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
            oAuth2Manager.authorisationProcessFail(withError: ErrorGenerator.oAuthAuthorizationURLError.generate())
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
            oAuth2Manager.authorisationProcessFail(withError: ErrorGenerator.noInternetConnectionError.generate())
            controller.dismissViewControllerAnimated(true, completion: nil)
            return
        }
    }
    
    //In case user close safari VC
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        oAuth2Manager.authorisationProcessFail()
    }
    
    func oAuthTokenRequestResponseReceived(notification: NSNotification) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MasterViewController: OAuth2ManagerDelegate {
    func authorisationStatusDidChanged(authorisationStatus: OAuth2Manager.AuthorisationStatus) {
        loadInitialData()
    }
}

