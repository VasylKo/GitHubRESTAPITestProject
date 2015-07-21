//
//  AddMenuView.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class AddMenuView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    var menuWidth: CGFloat = 150 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var direction: AnimationDirection = .TopRight
    var items: [MenuItem] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startButton.frame = bounds
        tableView.frame = menuRect(direction)
    }

    
    private let startButton = AddMenuButton(image: UIImage(named: "AddIcon")!)
    private let tableView = UITableView()
    private let cellReuseId: String = NSStringFromClass(AddMenuItemCell.self)!
}

//MARK: Types
extension AddMenuView {
    enum AnimationDirection {
        case TopRight
    }
    
    struct MenuItem {
        let title: String?
        let icon: UIImage?
        let color: UIColor
    }
    
}


//MARK: Private
extension AddMenuView {
    private func configure() {
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        addSubview(startButton)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        addSubview(tableView)
        tableView.registerNib(UINib(nibName: cellReuseId, bundle: nil), forCellReuseIdentifier: cellReuseId)
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
        items = [
            AddMenuView.MenuItem(title: "invite", icon: UIImage(named: "AddFriend"), color: UIColor.redColor()),
            AddMenuView.MenuItem(title: "Promotion", icon: UIImage(named: "AddPromotion"), color: UIColor.greenColor()),
            AddMenuView.MenuItem(title: "Event", icon: UIImage(named: "AddEvent"), color: UIColor.blueColor()),
            AddMenuView.MenuItem(title: "Product", icon: UIImage(named: "AddProduct"), color: UIColor.yellowColor()),
        ]
        
        tableView.reloadData()
    }
    private func menuRect(direction: AnimationDirection) -> CGRect {
        let height: CGFloat = tableView.estimatedRowHeight * CGFloat(tableView(tableView, numberOfRowsInSection: 0))
        switch direction {
        case .TopRight:
            return CGRect(x: 0, y: -height, width: menuWidth, height: height)
        default:
            return CGRectZero
        }
    }
}

//MARK: Table
extension AddMenuView: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId) as? AddMenuItemCell {
            cell.titleLabel?.text = item.title
            cell.button?.image = item.icon
            cell.button?.fillColor = item.color
            return cell
        }
        fatalError("Could not deque \(cellReuseId)")
    }
}


class AddMenuItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: AddMenuButton!
    
}
