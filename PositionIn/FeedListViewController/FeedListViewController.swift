//
//  FeedListViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import BrightFutures
import UIKit

class FeedListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var feauteredFeedItem: FeedItem?
    private var feedItems: [FeedItem]?
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        self.loadData()
        setNavigationButtons()
    }

    private func setNavigationButtons() {
        //Add image to Bavigation Bar
        let imageView = UIImageView(image: UIImage(named: "feed-logo")?.imageWithRenderingMode(.AlwaysOriginal))
        let barButtonItem = UIBarButtonItem(customView: imageView)
        
        //Add button with negative width to stick above image to left edge
        let negativeSeparator = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSeparator.width = -17
        //Call parent view controller with navigation bar (BrowseMainGridController) where we whant to add notification button
        parentViewController?.navigationItem.rightBarButtonItems = [negativeSeparator,barButtonItem]
    }

    private func setupInterface() {
        
        var nib = UINib(nibName: String(FeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeedTableViewCell.self))
        nib = UINib(nibName:  String(FeauteredFeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeauteredFeedTableViewCell.self))
    }
    
    //MARK: Load data
    
    func loadData () {
        self.tableView.hidden = true
        var filter = SearchFilter()
        filter.isFeatured = true
        filter.categories = nil
        filter.startPrice = nil
        filter.endPrice = nil
        var page = APIService.Page(start: 0, size: 1)
        
        api().getFeed(filter, page: page).flatMap { [weak self] (response: CollectionResponse<FeedItem>) -> Future<CollectionResponse<FeedItem>, NSError> in
            self?.feauteredFeedItem = response.items.first
            
            page = APIService.Page(start: 0, size: 100)
            filter.isFeatured = false
            
            return api().getFeed(filter, page: page)
            
            }.onSuccess {[weak self] (response: CollectionResponse<FeedItem>) -> Void in
                self?.feedItems = response.items
                self?.tableView.reloadData()
                self?.tableView.contentSize = CGSize(width: self!.tableView.contentSize.width,
                    height: self!.tableView.contentSize.height + 20)
                self?.tableView.hidden = false
        }
    }
}


extension FeedListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        var item:FeedItem?
        var isFeautered = false
        if indexPath.row == 0 && (self.feauteredFeedItem != nil) {
            item = self.feauteredFeedItem
            isFeautered = true
        }
        else {
            let offset = (self.feauteredFeedItem != nil) ? 1 : 0
            item = self.feedItems![indexPath.row - offset]
        }
        
        if (item!.type == .Emergency) {
            let detailsController = FeedEmergencyDetailsViewController(nibName: "FeedEmergencyDetailsViewController",
                bundle: nil)
            detailsController.objectId = item?.objectId
            detailsController.isFeautered = isFeautered
            self.navigationController?.pushViewController(detailsController, animated: true)
        }
        else {
            let detailsController = NewsDetailsViewController(nibName: "NewsDetailsViewController",
                bundle: nil)
            
            detailsController.objectId = item?.objectId
            detailsController.isFeautered = isFeautered
            self.navigationController?.pushViewController(detailsController, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension FeedListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        if let _ = feauteredFeedItem {
            numberOfRowsInSection += 1
        }
        if let feedItems = feedItems {
            numberOfRowsInSection += feedItems.count
        }
        return numberOfRowsInSection
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (feauteredFeedItem != nil) && indexPath.row == 0 {
            return 284
        }
        else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        if indexPath.row == 0 && (self.feauteredFeedItem != nil) {
            let feauteredCell = tableView.dequeueReusableCellWithIdentifier(String(FeauteredFeedTableViewCell.self),
                forIndexPath: indexPath) as! FeauteredFeedTableViewCell
            let imagePlaceholder = (self.feauteredFeedItem?.type == .Emergency) ? "PromotionDetailsPlaceholder" : "news_placeholder"
            feauteredCell.setImageURL(self.feauteredFeedItem?.image, placeholder: imagePlaceholder)
            feauteredCell.titleString = self.feauteredFeedItem?.name
            cell = feauteredCell
        }
        else {
            let feedItemCell = tableView.dequeueReusableCellWithIdentifier(String(FeedTableViewCell.self),
                forIndexPath: indexPath) as! FeedTableViewCell
            
            let offset = (self.feauteredFeedItem != nil) ? 1 : 0
            
            let feedItem = self.feedItems![indexPath.row - offset]
            let imagePlaceholder = (feedItem.type == .Emergency) ? "PromotionDetailsPlaceholder" : "news_placeholder"
            feedItemCell.setImageURL(feedItem.image, placeholder: imagePlaceholder)
            feedItemCell.titleString = feedItem.name
            if let title = feedItem.author?.title {
                feedItemCell.authorString = "By \(title)"
            }
            feedItemCell.timeAgoString = feedItem.date?.formattedAsFeedTime()
            cell = feedItemCell
        }
        return cell!
    }
}
