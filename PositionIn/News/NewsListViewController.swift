//
//  NewsListViewController.swift
//  PositionIn
//
//  Created by ng on 2/16/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import PosInCore
import BrightFutures
import CleanroomLogger

protocol NewsListActionConsumer: class {
    func showNewsDetails(id: CRUDObjectId)
    func like(item: FeedItem)
}

class NewsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: TableView!
    private var dataRequestToken = InvalidationToken()
    private var filter: SearchFilter {
        var filter = SearchFilter.currentFilter
        filter.itemTypes = [.News]
        return filter
    }
    
    lazy var dataSource: NewsListDataSource = { [unowned self] in
        let dataSource = NewsListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("KRCS News")
        
        dataSource.configureTable(self.tableView)
        self.reloadData()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let fromViewController = self.navigationController?.transitionCoordinator()?.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            if self.navigationController?.viewControllers.contains(fromViewController) == false {
                self.reloadData()
            }
        }
    }
    
    //MARK: Data
    
    func reloadData() {
        getFeedItems(filter)
    }
    
    private func getFeedItems(searchFilter: SearchFilter, page: APIService.Page = APIService.Page()) {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        
        let request: Future<CollectionResponse<FeedItem>, NSError> = api().getAll(.News, seachFilter: self.filter)
        request.onSuccess(dataRequestToken.validContext) {
            [weak self] response in
            if let strongSelf = self {
                let items: [FeedItem] = response.items
                strongSelf.dataSource.setItems(items)
                strongSelf.tableView.reloadData()
                strongSelf.tableView.setContentOffset(CGPointZero, animated: false)
            }
        }
    }
    
    var items : [FeedItem]?
}

extension NewsListViewController: NewsListActionConsumer {
    
    func showNewsDetails(id: CRUDObjectId) {
        trackGoogleAnalyticsEvent("Main", action: "Click", label: "Post")
        let controller = Storyboards.Main.instantiatePostViewController()
        controller.objectId = id
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func like(item: FeedItem) {
        if (item.isLiked) {
            api().unlikePost(item.objectId).onSuccess{[weak self] in
                self?.reloadData()
            }
        }
        else {
            api().likePost(item.objectId).onSuccess{[weak self] in
                self?.reloadData()
            }
        }
    }
}

extension NewsListViewController {
    
    internal class NewsListDataSource: TableViewDataSource {
        
        private var models: [[TableViewCellModel]] = []
        private let cellFactory = NewsCellModelFactory()
        var actionConsumer: NewsListActionConsumer? {
            return parentViewController as? NewsListActionConsumer
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return models.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return models[section].count
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return models[indexPath.section][indexPath.row]
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return cellFactory.cellReuseIdForModel(self.tableView(tableView, modelForIndexPath: indexPath))
        }
        
        override func nibCellsId() -> [String] {
            return self.cellFactory.cellsReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? NewsTableViewCellModel {
                self.actionConsumer?.showNewsDetails(model.item.objectId)
            }
        }
        
        func setItems(feedItems: [FeedItem]) {
            let list = feedItems.reduce([]) { models, feedItem  in
                return models + self.cellFactory.model(feedItem, actionConsumer: self.actionConsumer)
            }
            self.models = list
        }
    }
}