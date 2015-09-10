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
    
    func initializeForm() {
        let filter = SearchFilter.currentFilter
        
        let form = XLFormDescriptor(title: NSLocalizedString("Filter", comment: "Update filter: form caption"))

        //Options
        let optionsSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Options", comment: "Update filter: options caption"))
        form.addFormSection(optionsSection)
        
        //Price
        currencyFormatter.numberStyle = .CurrencyStyle
        
        let priceRow = XLFormRowDescriptor(tag: Tags.EndPrice.rawValue, rowType: XLFormRowDescriptorTypeSlider, title: "")
        let startPriceTitle = NSLocalizedString("Price up to", comment: "Update filter: price")
        
        let updatePriceValue: (XLFormRowDescriptor, String, Float) -> () = { [weak self] descriptor, localizedTitle, value in
            let stringValue: String  = self?.currencyFormatter.stringFromNumber(value) ?? ""
            descriptor.title = String(format: "%@: %@", localizedTitle, stringValue)
            self?.reloadFormRow(descriptor)
        }

        let priceChangeBlock: XLOnChangeBlock = {  oldValue, newValue, descriptor in
            let newValue = newValue as! Float
            updatePriceValue(descriptor, startPriceTitle, newValue)
        }
        
        priceRow.onChangeBlock = priceChangeBlock
        priceRow.value = filter.endPrice ?? SearchFilter.maxPrice
        priceRow.cellConfigAtConfigure["slider.maximumValue"] = SearchFilter.maxPrice
        priceRow.cellConfigAtConfigure["slider.minimumValue"] = SearchFilter.minPrice
        priceRow.cellConfigAtConfigure["steps"] = SearchFilter.Money(100)
        optionsSection.addFormRow(priceRow)
        
        //Radius
        let radiusRow = XLFormRowDescriptor(tag: Tags.Radius.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: NSLocalizedString("Distance", comment: "Update filter: radius value"))
        let radiusOptions = [
            XLFormOptionsObject(value: 1, displayText: NSLocalizedString("1 km", comment: "Update filter: radius 1km")),
            XLFormOptionsObject(value: 5, displayText: NSLocalizedString("5 km", comment: "Update filter: radius 5km")),
            XLFormOptionsObject(value: 20, displayText: NSLocalizedString("20 km", comment: "Update filter: radius 20km")),
            XLFormOptionsObject(value: 100, displayText: NSLocalizedString("100 km", comment: "Update filter: radius 100km")),
        ]
        radiusRow.selectorOptions = radiusOptions
        radiusRow.value = radiusOptions.first
        optionsSection.addFormRow(radiusRow)
        
        //Time
        let timeRow = XLFormRowDescriptor(tag: Tags.Time.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: NSLocalizedString("Time", comment: "Update filter: time value"))
        let rawDateRanges: [DateRange] = [.Now, .Today, .Tomorrow, .Week, .Custom]
        let dateOptions: [XLFormOptionsObject] = rawDateRanges.map {
            XLFormOptionsObject(value: $0.rawValue, displayText: $0.displayString())
        }
        timeRow.selectorOptions = dateOptions
        timeRow.value = dateOptions.first
        optionsSection.addFormRow(timeRow)
        
        let customDateStatePredicate = NSPredicate(format: "NOT $\(Tags.Time.rawValue).value.formValue == \(DateRange.Custom.rawValue)")
        
        //Start date
        let startDateRow = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTime, title: NSLocalizedString("Start date", comment: "New event: Start date"))
        startDateRow.value = NSDate(timeIntervalSinceNow: -60*60*24)
        startDateRow.disabled = customDateStatePredicate
        optionsSection.addFormRow(startDateRow)
        //End date
        let endDateRow = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTime, title: NSLocalizedString("End date", comment: "New event: End date"))
        endDateRow.value = NSDate(timeIntervalSinceNow: 60*60*25)
        endDateRow.disabled = customDateStatePredicate
        optionsSection.addFormRow(endDateRow)
        
        //(AnyObject?, AnyObject?, XLFormRowDescriptor) -> Void
        timeRow.onChangeBlock = { [weak startDateRow, weak endDateRow] _, newValue, descriptor in
            if let option = newValue as? XLFormOptionsObject,
                let rawValue = option.formValue() as? Int,
                let range = DateRange(rawValue: rawValue) {
                    let (startDate, endDate) = range.dates()
                    startDateRow?.value = startDate
                    endDateRow?.value = endDate
            }
        }
        
        //TODO: validate start date < end date
        
        //Categories
        
        let filterCategories = filter.categories
        Log.debug?.value(filterCategories)
        let categoryValue: (ItemCategory) -> Bool = { category in
            if let filterCategories = filterCategories {
                return contains(filterCategories, category) || contains(filterCategories, .Unknown)
            } else {
                return true
            }
        }

        
        let categoriesSection = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Categories", comment: "Update filter: categories caption"))
        categoriesSection.multivaluedTag = Tags.Categories.rawValue
        form.addFormSection(categoriesSection)
        let categories = ItemCategory.all()
        categories.map { (category: ItemCategory) -> () in
            let categoryRow = XLFormRowDescriptor(tag: category.displayString(), rowType: XLFormRowDescriptorTypeBooleanSwitch, title: category.displayString())
            categoryRow.cellConfigAtConfigure["imageView.image"] = category.image()
            let value = categoryValue(category)
            categoryRow.value = NSNumber(bool: value)
            categoriesSection.addFormRow(categoryRow)
        }
        
        self.form = form
    }
    
    
    @IBAction func didTapApply(sender: AnyObject) {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        
        let values = formValues()
        Log.debug?.value(values)
        Log.debug?.value(categoriesValue(values[Tags.Categories.rawValue]))
        
        var filter = SearchFilter.currentFilter
        filter.categories = categoriesValue(values[Tags.Categories.rawValue])
        filter.endPrice = values[Tags.EndPrice.rawValue] as?  SearchFilter.Money
        SearchFilter.currentFilter = filter
        didTapCancel(sender)
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func categoriesValue(values: AnyObject?) -> [ItemCategory]? {
        if let values = values as? [NSNumber] {
            let categories = ItemCategory.all()
            var result: [ItemCategory] = []
            for (idx, value) in enumerate(values) {
                if value.boolValue == true {
                    result.append(categories[idx])
                }
            }
            return result
        }
        return nil
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
        
        func dates() -> (NSDate, NSDate) {
            return (NSDate(), NSDate())
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
