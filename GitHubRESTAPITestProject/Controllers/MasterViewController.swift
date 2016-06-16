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
    private lazy var addBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.createNewGist(_:)))
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
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Add observer
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(self.oAuthTokenRequestResponseReceived(_:)), name: OAuthTokenRequestResponseReceivedNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.networkIsReachableNotification(_:)), name: GitHubAPIManager.networkIsReachableNotification, object: nil)
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
    
    //MARK: - UI
    private func updateUI() {
        // only show add button for my gists
        guard let selectedState = SegmenterIndexSections(rawValue: gistSegmentedControl.selectedSegmentIndex) else { fatalError("Index not found! Check SegmenterIndexSections Enum") }
        //if my gist is selected and usr is authorized show edit and create gist buttons
        if case .myGists = selectedState, .hasToken = oAuth2Manager.oAuthStatus {
            navigationItem.leftBarButtonItem = editButtonItem()
            navigationItem.rightBarButtonItem = addBarButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    //MARK: - Login View
    func showOAuthLoginView() {
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController where presentedViewController == nil {
            loginVC.delegate = self
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Reachability notification
    @objc private func networkIsReachableNotification(object: AnyObject) {
        refresh(nil)
    }
    
    //MARK: - Refresh controll
    func refresh(sender: AnyObject?) {
        loadInitialData()
    }
    
    //MARK: - Network Call
    ///Load lists of gists if the user is authorized
    private func loadInitialData() {
        guard let selectedSegmentIndex = SegmenterIndexSections(rawValue: gistSegmentedControl.selectedSegmentIndex) else { fatalError("Can't get selected segmented section. Check SegmenterIndexSections enum values") }
        
        switch oAuth2Manager.oAuthStatus {
        case .notAuthorised where selectedSegmentIndex == .publicGists:
            loadGists()
        case .notAuthorised(let error):
            //Hide refresh controll
            if refreshControl != nil && refreshControl!.refreshing {
                refreshControl!.endRefreshing()
            }
            if let error = error {
                showMessage(type: .warning, title: "Can't load gists", subtitle: error.localizedDescription)
                oAuth2Manager.resetAuthorisationStatus()
            } else  {
                showOAuthLoginView()
            }
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
                print("ERROR: \(result.error!.localizedDescription)")
                //Show error to the user
                showMessage(type: .warning, title: "Could not load gists.", subtitle: result.error!.localizedDescription)
                if result.error!.code == NSURLErrorUserAuthenticationRequired {
                    strongSelf.oAuth2Manager.authorisationProcessFail(withError: result.error!)
                }
                
                //If there is no internet load last saved data
                if result.error!.code == NSURLErrorNotConnectedToInternet {
                    strongSelf.loadDataFromLocalStorage()
                    strongSelf.tableView.reloadData()
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
            
            strongSelf.saveDataToLocalStorage()
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
    
    //MARK: - Persist data
    private func saveDataToLocalStorage() {
        let path = getPathToPersistantData()
        PersistenceManager.saveArray(gists, path: path)
    }
    
    private func loadDataFromLocalStorage() {
        let path = getPathToPersistantData()
        
        if let archived:[Gist] = PersistenceManager.loadArray(path) {
            gists = archived
        } else {
            // don't have any saved gists
            self.gists = []
        }
    }
    
    private func getPathToPersistantData() -> PersistenceManager.Path {
        let path: PersistenceManager.Path
        
        guard let selectedSegmentIndex = SegmenterIndexSections(rawValue: gistSegmentedControl.selectedSegmentIndex) else { fatalError("Can't get selected segmented section. Check SegmenterIndexSections enum values") }
        switch  selectedSegmentIndex{
        case .publicGists:
            path = .publicGists
        case .starredGists:
            path = .starredGists
        case .myGists:
            path = .myGists
        }
        
        return path
    }
    
    // MARK: - Actions
    func createNewGist(sender: AnyObject) {
        let createNewGistViewController = CreateGistViewController(nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: createNewGistViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func deleteGistWithId(gistId: String, fromTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        GitHubAPIManager.sharedInstance.deleteGist(gistId, completionHandler: { [weak self] (error) in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                print("ERROR: \(error!.localizedDescription)")
                showMessage(type: .warning, title: "Can't delete gist", subtitle: error!.localizedDescription)
                return
            }
            //Delete gist from the table
            strongSelf.gists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        updateUI()
        
        // clear gists so they can't get shown for the wrong list
        gists = [Gist]()
        tableView.reloadData()
        
        loadInitialData()
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
        cell.textLabel!.text = gist.gistDescription
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
        if editingStyle == .Delete, let id = gists[indexPath.row].id  {
            deleteGistWithId(id, fromTableView: tableView, atIndexPath: indexPath)
        }
    }

}

// MARK: - LoginViewDelegate
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
    
    func didTapCancel() {
        oAuth2Manager.authorisationProcessFail(withError: ErrorGenerator.customError.generate(customDescription: "Authorization required"))
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Safari View Controller Delegate
extension MasterViewController: SFSafariViewControllerDelegate {
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        // Detect not being able to load the OAuth URL
        guard Alamofire.NetworkReachabilityManager()?.isReachable ?? false else {
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
        if case .hasToken = authorisationStatus {
            updateUI()
            loadInitialData()
        }
        
    }
}

