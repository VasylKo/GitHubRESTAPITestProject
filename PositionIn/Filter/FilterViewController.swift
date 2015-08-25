//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import XLForm
import CleanroomLogger

final class FilterViewController: XLFormViewController {
    
    private enum Tags : String {
        case Products = "Products"
        case Events = "Events"
        case Promotions = "Promotions"
        
        case Time = "Time"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    private let categories: [ItemCategory] = [
        .AnimalsPetSupplies, .ApparelAccessories, .ArtsEntertainment, .BabyToddler, .BusinessIndustrial,
        .CamerasOptics, .Electronics, .Food, .Furniture, .Hardware, .HealthBeauty, .HomeGarden, .LuggageBags,
        .Media, .OfficeSupplies, .ReligiousCeremonial, .Software, .SportingGoods, .ToysGames, .VehiclesParts
    ]
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Filter", comment: "Update filter: form caption"))
        //Types
        let typeSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Type", comment: "Update filter: type caption"))
        form.addFormSection(typeSection)
        typeSection.addFormRow(productsRow)
        typeSection.addFormRow(eventsRow)
        typeSection.addFormRow(promotionsRow)
        
        //Options
        let optionsSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Options", comment: "Update filter: options caption"))
        form.addFormSection(optionsSection)
        //Time
        let timeRow = XLFormRowDescriptor(tag: Tags.Time.rawValue, rowType:XLFormRowDescriptorTypeSelectorPickerViewInline, title:NSLocalizedString("Time", comment: "Update filter: time value"))
        timeRow.selectorOptions = ["Now", "Today", "Tomorrow", "Upcoming 7 days"]
        timeRow.value = "Now"
        optionsSection.addFormRow(timeRow)
        //TOO: localize strings
        //TODO: custom date range

        
        //Categories
        let categoriesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Categories", comment: "Update filter: categories caption"))
        form.addFormSection(categoriesSection)
        categories.map { (category: ItemCategory) -> () in
            let categoryRow = XLFormRowDescriptor(tag: category.string(), rowType: XLFormRowDescriptorTypeBooleanSwitch, title: category.string())
            categoryRow.cellConfigAtConfigure["imageView.image"] = category.image()
            categoriesSection.addFormRow(categoryRow)
        }
        
        self.form = form
    }
    
    private(set) lazy var productsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Products.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Products", comment: "Update filter: Products"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        return row
    }()
    
    private(set) lazy var eventsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Events.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Events", comment: "Update filter: Events"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        return row
    }()

    private(set) lazy var promotionsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Promotions.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Promotions", comment: "Update filter: Promotions"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        return row
        }()
    
    
    @IBAction func didTapApply(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)

        Log.debug?.message("Should apply filter")
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        Log.debug?.message("Should cancel filter")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension ItemCategory {
    func image() -> UIImage {
        switch self {
        case .Unknown:
            fallthrough
        default:
            return UIImage(named: "BrowseModeList")!
        }
    }
}
