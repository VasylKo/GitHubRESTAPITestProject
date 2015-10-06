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
    func didSelectItem(item: FeedItem?)
}

class ItemsSearchResultsController: NSObject {
    
    private var filter = SearchFilter.currentFilter
    
    init(table: TableView?, resultStorage: ItemsSearchResultStorage?, searchBar: UISearchBar?) {
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
                let models = self?.modelsArray(response)
                self?.resultStorage?.setItems(models!)
                self?.itemsTable?.reloadData()
                self?.itemsTable?.scrollEnabled = self?.itemsTable?.frame.size.height < self?.itemsTable?.contentSize.height
            }
        }
    }
    
    func modelsArray(response: QuickSearchResponse) -> [TableViewCellModel] {
        var tableViewModels: [TableViewCellModel] = []
        //TODO: localizedString
        
        let categories = self.modelsSubArrayFromEnum(response.categories, title: "TOP HIT",
            type: SearchItem.SearchItemType.Category)
        tableViewModels.extend(categories)
        
        let products = self.modelsSubArrayFromEnum(response.products, title: "PRODUCTS",
            type: SearchItem.SearchItemType.Product)
        tableViewModels.extend(products)
        
        let promotions = self.modelsSubArrayFromEnum(response.promotions, title: "PROMOTIONS",
            type: SearchItem.SearchItemType.Promotion)
        tableViewModels.extend(promotions)
        
        let events = self.modelsSubArrayFromEnum(response.events, title: "EVENTS",
            type: SearchItem.SearchItemType.Event)
        tableViewModels.extend(events)
        
        
        let community = self.modelsSubArrayFromEnum(response.communities, title: "COMMUNITY",
            type: SearchItem.SearchItemType.Community)
        tableViewModels.extend(community)
        
        
        let people = self.modelsSubArrayFromEnum(response.peoples, title: "PEOPLE",
            type: SearchItem.SearchItemType.People)
        tableViewModels.extend(people)
        
        return tableViewModels
    }
    
    func modelsSubArrayFromEnum<T>(array: Array<T>, title: String, type:SearchItem.SearchItemType)
        -> [TableViewCellModel] {
            var tableViewModels: [TableViewCellModel] = []
            
            for var i = 0; i < array.count; i++ {
                
                var isHeaderCellTappable: Bool = false
                
                switch type {
                case .Unknown:
                    break
                case .Category:
                    if let model = array[i] as? ItemCategory  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: String(model.rawValue),
                            title: model.displayString(), searchString: searchBar?.text, subtitle: nil, localImageName: "placeholderProduct", remoteImageURL: nil)
                        tableViewModels.append(searchItemCellModel)
                    }
                case .Event:
                    if let model = array[i] as? ObjectInfo  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                            title: model.title, searchString: searchBar?.text, subtitle: nil, localImageName: "placeholderEvent", remoteImageURL: nil)
                        tableViewModels.append(searchItemCellModel)
                        isHeaderCellTappable = true
                    }
                case .Product:
                    if let model = array[i] as? ObjectInfo  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                            title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderProduct", remoteImageURL: nil)
                        tableViewModels.append(searchItemCellModel)
                        isHeaderCellTappable = true
                    }
                case .Promotion:
                    if let model = array[i] as? ObjectInfo  {
                        let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                            title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderPromotion", remoteImageURL: nil)
                        tableViewModels.append(searchItemCellModel)
                        isHeaderCellTappable = true
                    }
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
                    //TODO: OBJ ID
                    let model = SearchSectionCellModel(objectID: "", title: title,
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
    private weak var searchBar: UISearchBar?
    private var dataRequestToken = InvalidationToken()
    private var searchTimer: NSTimer?
    
    let searchDelay: NSTimeInterval = 1.5
}

extension ItemsSearchResultsController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        shouldReloadSearch()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        shouldReloadSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        delegate?.shouldDisplayItemsSearchResults()
    }
}