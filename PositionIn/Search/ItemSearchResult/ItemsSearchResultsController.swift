//
//  ItemSearchResultsController.swift
//  PositionIn
//
//  Created by mpol on 10/1/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger
import BrightFutures

protocol ItemsSearchResultStorage: class {
    func setItems(feedItems: [TableViewCellModel])
}

protocol ItemsSearchResultsDelegate: class {
    func shouldDisplayItemsSearchResults()
    func didSelectModel(model: TableViewCellModel?)
}

class ItemsSearchResultsController: NSObject {
    
    private var filter = SearchFilter.currentFilter
    
    init(table: TableView?, resultStorage: ItemsSearchResultStorage?, searchBar: UITextField?) {
        itemsTable = table
        self.resultStorage = resultStorage
        self.searchBar = searchBar
        super.init()
        searchBar?.delegate = self
    }
    
    func shouldReloadSearch() {
        searchTimer?.invalidate()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(searchDelay, target: self, selector: "reloadSearch", userInfo: nil, repeats: false)
    }
    
    func reloadSearch() {
        dataRequestToken.invalidate()
        dataRequestToken = InvalidationToken()
        let completion: ([[FeedItem]]) -> Void = { [weak self] items in
            
        }
        let searchString = map(searchBar?.text) { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        if let searchString = searchString where count(searchString) > 0 {
            
            Log.info?.message("Search string: \(searchString)")
            var f = filter
            f.name = searchString
            api().getSearchFeed(f, page: APIService.Page()).onSuccess(token: dataRequestToken) {
                [weak self] response in
                let models = self?.modelsForResponse(response)
                self?.resultStorage?.setItems(models!)
                self?.itemsTable?.reloadData()
                self?.itemsTable?.scrollEnabled = self?.itemsTable?.frame.size.height < self?.itemsTable?.contentSize.height
            }
        }
    }
    
    func modelsForResponse(response: QuickSearchResponse) -> [TableViewCellModel] {
        var tableViewModels: [TableViewCellModel] = []
        
        let products = self.modelsSubArrayFromResponseArray(response.products, title: NSLocalizedString("PRODUCTS",
            comment: "quick search"),
            type: SearchItem.SearchItemType.Product)
        tableViewModels.extend(products)
        
        let promotions = self.modelsSubArrayFromResponseArray(response.promotions, title: NSLocalizedString("PROMOTIONS",
            comment: "quick search"),
            type: SearchItem.SearchItemType.Promotion)
        tableViewModels.extend(promotions)
        
        let events = self.modelsSubArrayFromResponseArray(response.events, title: NSLocalizedString("EVENTS",
            comment: "quick search"),
            type: SearchItem.SearchItemType.Event)
        tableViewModels.extend(events)
        
        
        let community = self.modelsSubArrayFromResponseArray(response.communities, title: NSLocalizedString("COMMUNITY",
            comment: "quick search"),
            type: SearchItem.SearchItemType.Community)
        tableViewModels.extend(community)
        
        
        let people = self.modelsSubArrayFromResponseArray(response.peoples, title: NSLocalizedString("PEOPLE",
            comment: "quick search"),
            type: SearchItem.SearchItemType.People)
        tableViewModels.extend(people)
        
        return tableViewModels
    }
    
    func modelsSubArrayFromResponseArray(array: Array<ObjectInfo>, title: String, type:SearchItem.SearchItemType)
        -> [TableViewCellModel] {
            var tableViewModels: [TableViewCellModel] = []
            
            for var i = 0; i < array.count; i++ {
                
                var isHeaderCellTappable: Bool = false
                
                switch type {
                case .Unknown:
                    break
                case .Category:
                    break
                case .Event:
                    let model = array[i]
                    let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                        title: model.title, searchString: searchBar?.text, subtitle: nil, localImageName: "placeholderEvent", remoteImageURL: nil)
                    tableViewModels.append(searchItemCellModel)
                    isHeaderCellTappable = true
                case .Product:
                    let model = array[i]
                    let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                        title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderProduct", remoteImageURL: nil)
                    tableViewModels.append(searchItemCellModel)
                    isHeaderCellTappable = true
                    
                case .Promotion:
                    let model = array[i]
                    let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                        title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderPromotion", remoteImageURL: nil)
                    tableViewModels.append(searchItemCellModel)
                    isHeaderCellTappable = true
                case .Community:
                    if let model = array[i] as? UserInfo  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                            title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderCommunity", remoteImageURL: nil)
                        
                        tableViewModels.append(searchItemCellModel)
                    }
                case .People:
                    if let model = array[i] as? UserInfo  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                            title: model.title, searchString: searchBar?.text, subtitle: nil,
                            localImageName: "AvatarPlaceholder", remoteImageURL: model.avatar)
                        
                        tableViewModels.append(searchItemCellModel)
                    }
                    
                default:
                    print("")
                }
                
                if (i == 0) {
                    let model = SearchSectionCellModel(itemType: type, title: title,
                        isTappable: isHeaderCellTappable)
                    tableViewModels.insert(model, atIndex: 0)
                }
            }
            
            return tableViewModels
    }
    
    deinit {
        searchTimer?.invalidate()
    }
    
    weak var delegate: ItemsSearchResultsDelegate?
    private weak var resultStorage: ItemsSearchResultStorage?
    private weak var itemsTable: TableView?
    private weak var searchBar: UITextField?
    private var dataRequestToken = InvalidationToken()
    private var searchTimer: NSTimer?
    
    let searchDelay: NSTimeInterval = 1.5
}

extension ItemsSearchResultsController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        shouldReloadSearch()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.shouldDisplayItemsSearchResults()
    }
}