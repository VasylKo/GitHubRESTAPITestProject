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
    func didSearchString()
}

class ItemsSearchResultsController: NSObject {
    
    var filter = SearchFilter.currentFilter
    
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
        let searchString = searchBar?.text.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        if let searchString = searchString where searchString.characters.count > 0 {
            
            Log.info?.message("Search string: \(searchString)")
            var f = filter
            f.name = searchString
            api().getSearchFeed(f, page: APIService.Page()).onSuccess(dataRequestToken.validContext) {
                [weak self] response in
                guard let strongSelf = self, let table = strongSelf.itemsTable else {
                    return
                }
                let models = strongSelf.modelsForResponse(response)
                strongSelf.resultStorage?.setItems(models)
                table.reloadData()
                table.scrollEnabled = table.frame.size.height < table.contentSize.height
            }
        }
    }
    
    func modelsForResponse(response: QuickSearchResponse) -> [TableViewCellModel] {
        let responseData: [(type: SearchItem.SearchItemType, title: String, items: [ObjectInfo])] = [
            (.Product, NSLocalizedString("PRODUCTS", comment: "quick search"), response.products),
            (.Promotion, NSLocalizedString("PROMOTIONS", comment: "quick search"),response.promotions),
            (.Event, NSLocalizedString("EVENTS", comment: "quick search"), response.events),
            (.Community, NSLocalizedString("COMMUNITIES", comment: "quick search"), response.communities),
            (.People, NSLocalizedString("PEOPLE", comment: "quick search"), response.peoples)
        ]
        
        let tableViewModels = responseData.reduce([]) { result, data in
            result + self.modelsSubArrayFromResponseArray(data.items, title: data.title, type: data.type)
        }
        
        return tableViewModels
    }
    
    
    //TODO: rename
    func modelsSubArrayFromResponseArray(array: Array<ObjectInfo>, title: String, type:SearchItem.SearchItemType)
        -> [TableViewCellModel] {
            var tableViewModels: [TableViewCellModel] = []
            
            for var i = 0; i < array.count; i++ {
                
                var isHeaderCellTappable: Bool = false
                var feedItemType: FeedItem.ItemType = FeedItem.ItemType.Unknown
                
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
                    feedItemType = FeedItem.ItemType.Event
                case .Product:
                    let model = array[i]
                    let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                        title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderProduct", remoteImageURL: nil)
                    tableViewModels.append(searchItemCellModel)
                    isHeaderCellTappable = true
                    feedItemType = FeedItem.ItemType.Item
                case .Promotion:
                    let model = array[i]
                    let searchItemCellModel = SearchItemCellModel(itemType: type, objectID: model.objectId,
                        title: model.title, searchString: searchBar?.text,subtitle: nil, localImageName: "placeholderPromotion", remoteImageURL: nil)
                    tableViewModels.append(searchItemCellModel)
                    isHeaderCellTappable = true
                    feedItemType = FeedItem.ItemType.Promotion
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
                    let model = SearchSectionCellModel(itemType: feedItemType, title: title,
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

    func textFieldDidEndEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.bt_colorWithBytesR(0, g: 0, b: 0, a: 102)
        let str = NSAttributedString(string: textField.placeholder!,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        textField.attributedPlaceholder = str
        textField.textColor = UIColor.whiteColor()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.bt_colorWithBytesR(255, g: 255, b: 255, a: 255)
        let str = NSAttributedString(string: textField.placeholder!,
            attributes: [NSForegroundColorAttributeName:UIColor(white: 201/255, alpha: 1)])
        textField.attributedPlaceholder = str
        delegate?.shouldDisplayItemsSearchResults()
        textField.textColor = UIColor.blackColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text where text.characters.count > 0 else {
            return true
        }
        self.delegate?.didSearchString()
        return true
    }
}
