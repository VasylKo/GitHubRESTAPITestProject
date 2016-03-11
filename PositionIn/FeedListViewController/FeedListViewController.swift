//
//  FeedListViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 10/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class FeedListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var feauteredFeedItem: FeedItem?
    private var feedItems: [FeedItem]?
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: String(FeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeedTableViewCell.self))
        nib = UINib(nibName:  String(FeauteredFeedTableViewCell.self), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(FeauteredFeedTableViewCell.self))
        
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        feed-logo
        let imageView = UIImageView(image: UIImage(named: "feed-logo")?.imageWithRenderingMode(.AlwaysOriginal))
        let barButtonItem = UIBarButtonItem(customView: imageView)
        self.navigationItem.titleView = imageView
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationItem.rightBarButtonItems = [barButtonItem]
        self.navigationController?.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    //MARK: LoadData
    
    func loadData () {
        
        var filter = SearchFilter()
        filter.isFeatured = true
        
        let group = dispatch_group_create()
        
        dispatch_group_enter(group)
        var page = APIService.Page(start: 0, size: 1)
        api().getFeed(filter, page: page).onSuccess(callback: { [weak self] response in
            self?.feauteredFeedItem = response.items.first
            dispatch_group_leave(group)
            }
        )
        
        page = APIService.Page(start: 0, size: 100)
        filter = SearchFilter()
        filter.itemTypes = [.Emergency, .News]
        dispatch_group_enter(group)
        api().getFeed(filter, page: page).onSuccess(callback: { [weak self] response in
            self?.feedItems = response.items
            dispatch_group_leave(group)
            }
        )
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.tableView.contentSize = CGSize(width: self.tableView.contentSize.width, height: self.tableView.contentSize.height + 20)
            //margin from bottom plus button
        })
    }
}


extension FeedListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: handle tap
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
            let imagePlaceholder = (feedItem.type == .Emergency) ? "home_emergencies" : "home_news"
            feedItemCell.setImageURL(feedItem.image, placeholder: imagePlaceholder)
            feedItemCell.titleString = feedItem.text
            feedItemCell.authorString = feedItem.name
            feedItemCell.timeAgoString = feedItem.date?.formattedAsTimeAgo()
            cell = feedItemCell
        }
        return cell!
    }
}
