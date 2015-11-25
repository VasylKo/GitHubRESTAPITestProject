//
//  BrowseGridViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BrowseGridViewController: UIViewController {

    private enum HomeItems: Int {
        case Emergency = 0
        case Ambulance = 1
        case GiveBlood = 2
        case News = 3
        case Membership = 4
        case Donate = 5
        case Training = 6
        case Events = 7
        case Projects = 8
        case Market = 9
        case BomaHotels = 10
        case Volunteer = 11
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let reuseIdentifier = NSStringFromClass(BrowseGridCollectionViewCell.self)
        self.collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(96, 96)
        flowLayout.minimumInteritemSpacing = 8
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    private func image(homeItem: HomeItems) -> UIImage? {
        switch homeItem {
        case .Emergency:
            return UIImage(named: "home_emergencies")
        case .Ambulance:
            return UIImage(named: "home_ambulance")
        case .GiveBlood:
            return UIImage(named: "home_blood")
        case .News:
            return UIImage(named: "home_news")
        case .Membership:
            return UIImage(named: "home_membership")
        case .Donate:
            return UIImage(named: "home_donate")
        case .Training:
            return UIImage(named: "home_training")
        case .Events:
            return UIImage(named: "home_event")
        case .Projects:
            return UIImage(named: "home_projects")
        case .Market:
            return UIImage(named: "home_market")
        case .BomaHotels:
            return UIImage(named: "home_hotel")
        case .Volunteer:
            return UIImage(named: "home_volunteer")
        }
    }
    
    private func name(homeItem: HomeItems) -> String? {
        switch homeItem {
        case .Emergency:
            return "Emergency"
        case .Ambulance:
            return "Ambulance"
        case .GiveBlood:
            return "Blood"
        case .News:
            return "News"
        case .Membership:
            return "Membership"
        case .Donate:
            return "Donate"
        case .Training:
            return "Training"
        case .Events:
            return "Events"
        case .Projects:
            return "Project"
        case .Market:
            return "Market"
        case .BomaHotels:
            return "Boma Hotels"
        case .Volunteer:
            return "Volunteer"
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
}

extension BrowseGridViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(BrowseGridCollectionViewCell.self), forIndexPath: indexPath)
        if let cell = cell as? BrowseGridCollectionViewCell {
            if let homeItem = HomeItems(rawValue: indexPath.row) {
                cell.name = self.name(homeItem)
                cell.image = self.image(homeItem)
            }
        }
        return cell
    }
}