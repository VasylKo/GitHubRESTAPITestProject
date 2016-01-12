//
//  PostToContainerViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger

class PostToContainerViewController: ContainerViewController, XLFormRowDescriptorViewController {

    var rowDescriptor : XLFormRowDescriptor?
    var rowDescriptorViewControllers : [XLFormRowDescriptorViewController]?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let communitySearchViewController = CommunitySearchViewController()
        let volunteerSearchViewController = VolunteerSearchViewController()
        containeredViewControllers = [communitySearchViewController, volunteerSearchViewController]
        rowDescriptorViewControllers = [communitySearchViewController, volunteerSearchViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = rowDescriptor?.tag
        segmentedControl.tintColor = UIScheme.mainThemeColor
        for rowDescriptorViewController : XLFormRowDescriptorViewController in rowDescriptorViewControllers! {
            rowDescriptorViewController.rowDescriptor = rowDescriptor
        }
        activeIndex = segmentedControl.selectedSegmentIndex
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        activeIndex = self.segmentedControl.selectedSegmentIndex
    }
//    func postToRowDescriptor(tag: String) -> XLFormRowDescriptor {
//        let postToCaption = NSLocalizedString("Post to", comment: "New item: comunity caption")
//        let postToRow = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeSelectorPush, title: postToCaption)
//        postToRow.selectorTitle = postToCaption
//        
//        let emptyCommunity: Community = {
//            var c = Community()
//            c.objectId = CRUDObjectInvalidId
//            c.name = NSLocalizedString("None", comment: "New item: empty community")
//            return c
//        }()
//        let emptyOption = XLFormOptionsObject.formOptionsObjectWithCommunity(emptyCommunity)
//        
//        postToRow.value =  emptyOption
//        postToRow.selectorOptions = [ emptyOption ]
//        api().currentUserId().flatMap { userId in
//            return api().getUserCommunities(userId)
//            }.onSuccess { [weak postToRow, weak self] response in
//                Log.debug?.value(response.items)
//                let options = [emptyOption] + response.items.map { XLFormOptionsObject.formOptionsObjectWithCommunity($0) }
//                postToRow?.selectorOptions = options
//                postToRow?.cellConfigAtConfigure["tintColor"] = UIScheme.mainThemeColor
//                if  let preselectedCommunity = self?.preselectedCommunity {
//                    let filteredOptions = options.filter { (option: XLFormOptionsObject!) -> Bool in
//                        if let communityId = option.communityId where communityId == preselectedCommunity {
//                            return true
//                        }
//                        return false
//                    }
//                    if let value = filteredOptions.first {
//                        postToRow?.value = value
//                        self?.postToTableView?.reloadData()
//                    }
//                }
//        }
//        
//        return postToRow
//    }
}
