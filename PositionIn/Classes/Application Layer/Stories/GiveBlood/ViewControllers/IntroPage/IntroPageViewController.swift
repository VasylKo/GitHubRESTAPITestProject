//
//  IntroPageViewController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 5/5/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class IntroPageViewController: UIViewController {

    private let router : GiveBloodRouter
    
    // MARK: - Init
    init(router: GiveBloodRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(IntroPageViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
