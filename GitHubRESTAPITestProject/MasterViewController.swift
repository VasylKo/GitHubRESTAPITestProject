//
//  MasterViewController.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasiliy Kotsiuba on 18/05/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import PINRemoteImage

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()
    var nextPageURLString: String?
    var isLoading = false
    
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
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadGists(nil)
    }
    
    //MARK: - Network Call
    func refresh(sender: AnyObject) {
        nextPageURLString = nil
        loadGists(nil)
    }
    
    //MARK: - Network Call
    func loadGists(urlToLoad: String?) {
        self.isLoading = true
        GitHubAPIManager.sharedInstance.getPublicGists(urlToLoad) {
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
        let rowsToLoadFromBottom = 5;
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

