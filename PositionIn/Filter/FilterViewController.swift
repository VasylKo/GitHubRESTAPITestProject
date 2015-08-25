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

        case StartPrice = "StartPrice"
        case EndPrice = "EndPrice"
        case Radius = "Radius"
        case Time = "Time"
        case StartDate = "StartDate"
        case EndDate = "EndDate"
        
        case Categories = "Categories"

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
        
        //Price
        currencyFormatter.numberStyle = .CurrencyStyle
        
        let startPriceRow = XLFormRowDescriptor(tag: Tags.StartPrice.rawValue, rowType: XLFormRowDescriptorTypeSlider, title: "")
        let endPriceRow = XLFormRowDescriptor(tag: Tags.EndPrice.rawValue, rowType: XLFormRowDescriptorTypeSlider, title: "")
        
        let updatePriceValue: (XLFormRowDescriptor, String, Float) -> () = { [weak self] descriptor, localizedTitle, value in
            let stringValue: String  = self?.currencyFormatter.stringFromNumber(value) ?? ""
            descriptor.title = String(format: "%@: %@", localizedTitle, stringValue)
            self?.reloadFormRow(descriptor)
        }

        let startPriceTitle = NSLocalizedString("Start price", comment: "Update filter: start price")
        let endPriceTitle = NSLocalizedString("End price", comment: "Update filter: end price")
        
        let startPriceChangeBlock: XLOnChangeBlock = {  oldValue, newValue, descriptor in
            let newValue = newValue as! Float
            let endPriceValue = endPriceRow.value as! Float
            if newValue < endPriceValue {
                updatePriceValue(descriptor, startPriceTitle, newValue)
            } else {
                descriptor.value = oldValue
            }
        }
        
        let endPriceChangeBlock: XLOnChangeBlock = {  oldValue, newValue, descriptor in
            let newValue = newValue as! Float
            let startPriceValue = startPriceRow.value as! Float
            if newValue > startPriceValue {
                updatePriceValue(descriptor, endPriceTitle, newValue)
            } else {
                descriptor.value = oldValue
            }
        }
        
        startPriceRow.onChangeBlock = startPriceChangeBlock
        startPriceRow.value = Float(10)
        startPriceRow.cellConfigAtConfigure["slider.maximumValue"] = Float(1000)
        startPriceRow.cellConfigAtConfigure["slider.minimumValue"] = Float(0)
        startPriceRow.cellConfigAtConfigure["steps"] = Float(10)
        optionsSection.addFormRow(startPriceRow)
        
        endPriceRow.onChangeBlock = endPriceChangeBlock
        endPriceRow.value = Float(900)
        endPriceRow.cellConfigAtConfigure["slider.maximumValue"] = Float(1000)
        endPriceRow.cellConfigAtConfigure["slider.minimumValue"] = Float(0)
        endPriceRow.cellConfigAtConfigure["steps"] = Float(10)
        optionsSection.addFormRow(endPriceRow)
        

        
        //Radius
        let radiusRow = XLFormRowDescriptor(tag: Tags.Radius.rawValue, rowType:XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Distance", comment: "Update filter: radius value"))
        let radiusOptions = [
            XLFormOptionsObject(value: 1000, displayText: NSLocalizedString("1 km", comment: "Update filter: radius 1km")),
            XLFormOptionsObject(value: 5000, displayText: NSLocalizedString("5 km", comment: "Update filter: radius 5km")),
            XLFormOptionsObject(value: 20000, displayText: NSLocalizedString("20 km", comment: "Update filter: radius 20km")),
            XLFormOptionsObject(value: 100000, displayText: NSLocalizedString("100 km", comment: "Update filter: radius 100km")),
        ]
        radiusRow.selectorOptions = radiusOptions
        radiusRow.value = radiusOptions.first
        optionsSection.addFormRow(radiusRow)
        
        //Time
        let timeRow = XLFormRowDescriptor(tag: Tags.Time.rawValue, rowType:XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Time", comment: "Update filter: time value"))
        let rawDateRanges: [DateRange] = [.Now, .Today, .Tomorrow, .Week, .Custom]
        let dateOptions: [XLFormOptionsObject] = rawDateRanges.map {
            XLFormOptionsObject(value: $0.rawValue, displayText: $0.displayString())
        }
        timeRow.selectorOptions = dateOptions
        timeRow.value = dateOptions.first
        optionsSection.addFormRow(timeRow)
        
        let customDateHiddenPredicate = NSPredicate(format: "NOT $\(Tags.Time.rawValue).value.formValue == \(DateRange.Custom.rawValue)")
        
        //Start date
        let startDate = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("Start date", comment: "New event: Start date"))
        startDate.value = NSDate(timeIntervalSinceNow: 60*60*24)
        startDate.hidden = customDateHiddenPredicate
        optionsSection.addFormRow(startDate)
        //End date
        let endDate = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTimeInline, title: NSLocalizedString("End date", comment: "New event: End date"))
        endDate.value = NSDate(timeIntervalSinceNow: 60*60*25)
        endDate.hidden = customDateHiddenPredicate
        optionsSection.addFormRow(endDate)


        
        //Categories
        let categoriesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Categories", comment: "Update filter: categories caption"))
        categoriesSection.multivaluedTag = Tags.Categories.rawValue
        form.addFormSection(categoriesSection)
        categories.map { (category: ItemCategory) -> () in
            let categoryRow = XLFormRowDescriptor(tag: category.displayString(), rowType: XLFormRowDescriptorTypeBooleanSwitch, title: category.displayString())
            categoryRow.cellConfigAtConfigure["imageView.image"] = category.image()
            categoryRow.value = NSNumber(bool: false)
            categoriesSection.addFormRow(categoryRow)
        }
        
        self.form = form
    }
    
    private(set) lazy var productsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Products.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Products", comment: "Update filter: Products"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        row.value = NSNumber(bool: true)
        return row
    }()
    
    private(set) lazy var eventsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Events.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Events", comment: "Update filter: Events"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        row.value = NSNumber(bool: true)
        return row
    }()

    private(set) lazy var promotionsRow: XLFormRowDescriptor = {
        let row = XLFormRowDescriptor(tag: Tags.Promotions.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("Promotions", comment: "Update filter: Promotions"))
        row.cellConfigAtConfigure["imageView.image"] = UIImage(named: "BrowseModeList")!
        row.value = NSNumber(bool: true)
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
    
    private let currencyFormatter = NSNumberFormatter()
    
    private enum DateRange: Int {
        case Now, Today, Tomorrow, Week, Custom
        
        func displayString() -> String {
            switch self {
            case .Now:
                return NSLocalizedString("Now", comment: "Date range: Now")
            case .Today:
                return NSLocalizedString("Today", comment: "Date range: Today")
            case .Tomorrow:
                return NSLocalizedString("Tomorrow", comment: "Date range: Tomorrow")
            case .Week:
                return NSLocalizedString("Upcoming 7 days", comment: "Date range: Week")
            case .Custom:
                return NSLocalizedString("Custom date range", comment: "Date range: Custom")
            }
        }
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
