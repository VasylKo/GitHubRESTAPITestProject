//
//  LocationSelectorViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import MapKit
import XLForm
import CleanroomLogger

@objc(LocationSelectorViewController)
class LocationSelectorViewController: UIViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor?
    
    
    lazy var mapView : MKMapView = {
        let mapView = MKMapView(frame: self.view.frame)
        self.view.addSubViewOnEntireSize(mapView)
        return mapView
        }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rowDesc = self.rowDescriptor,
           let value = rowDesc.value as? CLLocation {
            Log.debug?.value(value.coordinate)
            mapView.setCenterCoordinate(value.coordinate, animated: false)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


class CLLocationValueTrasformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            let location = valueData as! CLLocation
            return String(format: "%0.4f, %0.4f", location.coordinate.latitude, location.coordinate.longitude)
        }
        return nil
    }
    
}