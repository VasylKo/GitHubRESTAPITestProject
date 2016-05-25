//
//  NewsContainerViewController.swift
//  PositionIn
//
//  Created by ng on 2/18/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class NewsContainerViewController : BarButtonItemContainerViewController {
    
    convenience init() {
        let list = NewsListViewController()
        let map = NewsMapViewController()
        let appShortTitle = AppConfiguration().appShortTitle
        self.init(containeredViewControllers: [list, map],
                                       title: NSLocalizedString("\(appShortTitle) News"),
                                  imageNames: ["map_view_icon", "list_view_icon"])
    }
    

}