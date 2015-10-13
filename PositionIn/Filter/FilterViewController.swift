//
//  AddProductViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import XLForm
import CleanroomLogger
import BrightFutures

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
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.roundingMode = .RoundDown
        
        let priceRow = XLFormRowDescriptor(tag: Tags.EndPrice.rawValue, rowType: XLFormRowDescriptorTypeSlider, title: "")
        priceRow.onChangeBlock = { [weak self] oldValue, newValue, descriptor in
            let newValue = newValue as! Float
            let priceFormat = NSLocalizedString("Price up to: %@", comment: "Update filter: price format")
            let stringValue: String  = self?.currencyFormatter.stringFromNumber(newValue) ?? ""
            Queue.main.async { [weak descriptor, weak self] in
                descriptor?.title = String(format: priceFormat, stringValue)
                self?.reloadFormRow(descriptor)
            }
        }

        priceRow.cellConfigAtConfigure["slider.maximumValue"] = SearchFilter.maxPrice
        priceRow.cellConfigAtConfigure["slider.minimumValue"] = SearchFilter.minPrice
        priceRow.cellConfigAtConfigure["steps"] = SearchFilter.Money(400)
        priceRow.cellConfigAtConfigure["slider.minimumTrackTintColor"] = UIScheme.mainThemeColor
        priceRow.value = SearchFilter.defaultPrice
        optionsSection.addFormRow(priceRow)

        //Radius
        let radiusRow = XLFormRowDescriptor(tag: Tags.Radius.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: NSLocalizedString("Distance", comment: "Update filter: radius value"))
        let radiusItems: [SearchFilter.Distance] = [.Km1, .Km5, .Km20, .Km100, .Anywhere]
        let radiusOptions = radiusItems.map { XLFormOptionsObject.formOptionsObjectWithSearchDistance($0) }
        radiusRow.selectorOptions = radiusOptions
        radiusRow.value =  XLFormOptionsObject.formOptionsObjectWithSearchDistance( filter.distance ?? .Anywhere )
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
        let startDateRow = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDateTime, title: NSLocalizedString("Start date", comment: "Filter: Start date"))
        startDateRow.value = NSDate(timeIntervalSinceNow: -60*60*24)
        startDateRow.disabled = customDateStatePredicate
        optionsSection.addFormRow(startDateRow)
        //End date
        let endDateRow = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDateTime, title: NSLocalizedString("End date", comment: "Filter: End date"))
        endDateRow.value = NSDate(timeIntervalSinceNow: 60*60*25)
        endDateRow.disabled = customDateStatePredicate
        optionsSection.addFormRow(endDateRow)

        timeRow.onChangeBlock = { _, newValue, descriptor in
            if let option = newValue as? XLFormOptionsObject,
                let rawValue = option.formValue() as? Int,
                let range = DateRange(rawValue: rawValue) {
                    let (startDate, endDate) = range.dates()
                    Queue.main.async { [weak self] in
                        let startDateRow = self?.form.formRowWithTag(Tags.StartDate.rawValue)
                        let endDateRow = self?.form.formRowWithTag(Tags.EndDate.rawValue)
                        startDateRow?.value = startDate
                        endDateRow?.value = endDate
                        self?.reloadFormRow(startDateRow)
                        self?.reloadFormRow(endDateRow)
                    }
            }
        }
        //TODO: validate start date < end date

        
        //Categories
        
        let filterCategories = filter.categories
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
            categoryRow.cellConfig.setObject(UIColor.bt_colorWithBytesR(237, g: 27, b: 46), forKey: "switchControl.onTintColor")
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
        
        var filter = SearchFilter.currentFilter
        
        filter.categories = categoriesValue(values[Tags.Categories.rawValue])
        filter.endPrice = map(values[Tags.EndPrice.rawValue] as?  SearchFilter.Money) { round($0) }
        filter.distance = flatMap(values[Tags.Radius.rawValue] as? XLFormOptionsObject) { $0.searchDistance }
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
    
    //MARK: - Table fixes -
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let descriptor = form.formRowAtIndex(indexPath) where descriptor.rowType == XLFormRowDescriptorTypeBooleanSwitch {
            return 44.0
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
}


extension ItemCategory {
    func image() -> UIImage {
        switch self {
        case .AnimalsPetSupplies:
            return UIImage(named: "category_animals_pet_supplies")!
        case .ApparelAccessories:
            return UIImage(named: "category_apparel_accessories")!
        case .ArtsEntertainment:
            return UIImage(named: "category_arts_entertainment")!
        case .BabyToddler:
            return UIImage(named: "category_baby_toddler")!
        case .BusinessIndustrial:
            return UIImage(named: "category_business_industrial")!
        case .CamerasOptics:
            return UIImage(named: "category_cameras_optics")!
        case .Electronics:
            return UIImage(named: "category_electronics")!
        case .Food:
            return UIImage(named: "category_food")!
        case .Furniture:
            return UIImage(named: "category_furniture")!
        case .Hardware:
            return UIImage(named: "category_hardware")!
        case .HealthBeauty:
            return UIImage(named: "category_health_beauty")!
        case .HomeGarden:
            return UIImage(named: "category_home_garden")!
        case .LuggageBags:
            return UIImage(named: "category_luggage_bags")!
        case .Unknown:
            return UIImage()
        }
  }
}
