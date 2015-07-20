//
//  BrowseViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BrowseViewController: BesideMenuViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyMode(mode)

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    var mode: DisplayMode = .Map {
        didSet {
            if isViewLoaded() {
                applyMode(mode)
            }
        }
    }
    
    
    private func applyMode(mode: DisplayMode) {
        println("\(self) Apply: \(mode)")
    }
    
    enum DisplayMode: Printable {
        case Map
        case List
        
        var description: String {
            switch self {
            case .Map:
                return "Map browse mode"
            case .List:
                return "List browse mode"
            }
        }
    }
    
    
    @IBOutlet weak var contentView: UIView!
}
