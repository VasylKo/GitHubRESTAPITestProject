//
//  FetchViewLogic.swift
//  PositionIn
//
//  Created by iam on 23/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures
import CleanroomLogger

protocol FetchViewLogicDelegate : NSObjectProtocol {
    typealias FetchedObject : CRUDObject
    func fetchStatusChanged(isFetching : Bool)
    func didUpdateObjects(objects : [FetchedObject])
    func noContentAvailable()
}

class FetchViewLogic<U : CRUDObject, T : Fetcher, D : FetchViewLogicDelegate where T.FetchedObject == U, D.FetchedObject == U> {
    
    private let fetcher : T
    private var limit : Int
    private var offset : Int = 0
    private var innerObjects : [U] = []
    
    internal private(set) var isFetching : Bool = false {
        didSet {
            if oldValue != isFetching {
                self.delegate?.fetchStatusChanged(isFetching)
            }
        }
    }
    internal private(set) var canFetch : Bool = true {
        didSet {
            self.delegate?.noContentAvailable()
        }
    }
    internal private(set) var objects : [U] = [] {
        didSet {
            self.delegate?.didUpdateObjects(objects)
        }
    }
    internal weak var delegate : D?
    
    //MARK: Initialization
    
    init(with fetcher : T, limit : Int) {
        self.fetcher = fetcher
        self.limit = limit
    }
    
    //MARK: Public
    
    internal func fetch(searchString: String? = nil) {
        Log.error?.message("fetching with \(self.fetcher)...")
        if self.canFetch == true && self.isFetching == false {
            self.isFetching = true
            self.fetcher.fetch(self.limit, offset: self.offset, searchString: searchString).onSuccess { [weak self] response in
                if let strongSelf = self {
                    Log.error?.message("fetch success \(strongSelf)")
                    if response.total <= strongSelf.innerObjects.count + response.items.count {
                        strongSelf.canFetch = false
                    }
                    strongSelf.innerObjects += response.items
                    strongSelf.offset = strongSelf.innerObjects.count
                    strongSelf.isFetching = false
                    strongSelf.objects = strongSelf.innerObjects
                }
                }.onComplete { [weak self] _ in
                    self?.isFetching = false
            }
        }
    }
    
    internal func clearData() {
        self.offset = 0
        self.objects = []
        self.innerObjects = []
        self.canFetch = true
    }
    
    internal func refresh() {
        self.offset = 0
        self.objects = []
        self.innerObjects = []
        self.canFetch = true
        self.fetch()
    }
}