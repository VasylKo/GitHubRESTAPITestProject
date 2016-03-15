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
    }
    
    private func setupInterface() {
        
        var nib = UINib(nibName: String(FeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeedTableViewCell.self))
        nib = UINib(nibName:  String(FeauteredFeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeauteredFeedTableViewCell.self))
    }
    
    //MARK: Load data
    
    func loadData () {
        var filter = SearchFilter()
        filter.isFeatured = true
        var page = APIService.Page(start: 0, size: 1)
        
        api().getFeed(filter, page: page).flatMap { [weak self] (response: CollectionResponse<FeedItem>) -> Future<CollectionResponse<FeedItem>, NSError> in
            self?.feauteredFeedItem = response.items.first
            
            page = APIService.Page(start: 0, size: 100)
            filter = SearchFilter()
            filter.itemTypes = [.Emergency, .News]
            
            return api().getFeed(filter, page: page)
            
            }.onSuccess {[weak self] (response: CollectionResponse<FeedItem>) -> Void in
            self?.feedItems = response.items
            self?.tableView.reloadData()
            self?.tableView.contentSize = CGSize(width: self!.tableView.contentSize.width, height: self!.tableView.contentSize.height + 20)
        }
    }
}


extension FeedListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailsController = NewsDetailsViewController(nibName: "NewsDetailsViewController", bundle: nil)
        
        if indexPath.row == 0 {
            detailsController.objectId = self.feauteredFeedItem?.objectId
        }
        else {
            if let feedItems = self.feedItems {
                let feedItem = feedItems[indexPath.row - 1]
                detailsController.objectId = feedItem.objectId
            }
        }
        
        self.navigationController?.pushViewController(detailsController, animated: true)
        //should devide to post and emergency
        
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
        if indexPath.row == 0 {
            let feauteredCell = tableView.dequeueReusableCellWithIdentifier(String(FeauteredFeedTableViewCell.self),
                forIndexPath: indexPath) as! FeauteredFeedTableViewCell
            let imagePlaceholder = (self.feauteredFeedItem?.type == .Emergency) ? "PromotionDetailsPlaceholder" : "home_news"
            feauteredCell.setImageURL(self.feauteredFeedItem?.image, placeholder: imagePlaceholder)
            feauteredCell.titleString = self.feauteredFeedItem?.text
            cell = feauteredCell
        }
        else {
            let feedItemCell = tableView.dequeueReusableCellWithIdentifier(String(FeedTableViewCell.self),
                forIndexPath: indexPath) as! FeedTableViewCell
            
            let feedItem = self.feedItems![indexPath.row - 1]
            let imagePlaceholder = (feedItem.type == .Emergency) ? "PromotionDetailsPlaceholder" : "home_news"
            feedItemCell.setImageURL(feedItem.image, placeholder: imagePlaceholder)
            feedItemCell.titleString = feedItem.name
            if let title = feedItem.author?.title {
                feedItemCell.authorString = "By \(title)"
            }
            feedItemCell.timeAgoString = feedItem.date?.formattedAsTimeAgo()
            cell = feedItemCell
        }
        return cell!
    }
}
