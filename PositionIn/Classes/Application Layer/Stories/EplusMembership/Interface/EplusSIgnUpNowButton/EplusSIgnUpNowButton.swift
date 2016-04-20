//
//  EplusSIgnUpNowButton.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 15/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EplusSIgnUpNowButton: UIButton {


    @IBOutlet weak var signUpNowViewContainer: UIView!
    @IBOutlet weak var viewPlanViewContainer: UIView!
    enum EplusButtonType {
        case SignUP, AlreadyMember
    }
    
    var type: EplusButtonType = .SignUP {
        didSet {
            setupUI()
        }
    }


    // MARK: init methods
    convenience init(eplusButtonType: EplusButtonType) {
        self.init()
        type = eplusButtonType
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonSetup()
    }
    
    // MARK: setup view
    private func commonSetup() {
        let nibView = loadViewFromNib()
        nibView.frame = bounds
        addSubViewOnEntireSize(nibView)
        nibView.userInteractionEnabled = false
    }
    
    
    private func loadViewFromNib() -> UIView {
        let viewBundle = NSBundle(forClass: self.dynamicType)
        //  An exception will be thrown if the xib file with this class name not found,
        let view = viewBundle.loadNibNamed(String(self.dynamicType), owner: self, options: nil)[0]
        return view as! UIView
    }
    
    private func setupUI() {
        switch type {
        case .AlreadyMember:
            viewPlanViewContainer.hidden = false
            signUpNowViewContainer.hidden = true
        case .SignUP:
            viewPlanViewContainer.hidden = true
            signUpNowViewContainer.hidden = false
        }
    }

}
