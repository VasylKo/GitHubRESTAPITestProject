//
//  NewsMapViewController.swift
//  PositionIn
//
//  Created by ng on 2/18/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class NewsMapViewController : ContainerViewController, BrowseActionConsumer {
    
    //MARK: Initializer
    
    convenience init() {
        let map = Storyboards.Main.instantiateBrowseMapViewController()
        map.filter.itemTypes = [.News]
        
        self.init(nibName: String(NewsMapViewController.self), containeredViewControllers: [map])
        
        map.actionConsumer = self
    }

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activeIndex = 0
    }
    
    //MARK: BrowseActionConsumer
    
    func browseController(controller: BrowseActionProducer, didSelectItem object: Any, type itemType: FeedItem.ItemType, data: Any?) {
        trackGoogleAnalyticsEvent("Main", action: "Click", label: "Post")
        let controller = Storyboards.Main.instantiatePostViewController()
        controller.objectId = object as? CRUDObjectId
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func browseControllerDidChangeContent(controller: BrowseActionProducer) {
        
    }
    
}