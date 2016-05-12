//
//  UnableToDonateViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 12/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class UnableToDonateViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Init
    
    init(router: GiveBloodRouter) {
        self.router = router
        super.init(nibName: NSStringFromClass(self.dynamicType), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - UI
    
    func setupUI() {
        self.title = NSLocalizedString("Reason")
        
        let rightBarButtomItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: #selector(skipTapped))
        navigationItem.rightBarButtonItem = rightBarButtomItem
        
        sendButton.layer.cornerRadius = 2
        sendButton.layer.masksToBounds = false
        sendButton.layer.shadowColor = UIColor.blackColor().CGColor
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        sendButton.layer.shadowOpacity = 0.1
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.bt_colorFromHex("CCCCCC", alpha: 1).CGColor
        
        textView.text = "Type here (optional)..."
        textView.textColor = UIColor.lightGrayColor()
    }
    
    //MARK: - Action
    
    @objc private func skipTapped() {
        
    }
    
    //MARK: - UITextViewDelegate
    
    @IBAction private func sendTapped(sender: AnyObject) {
        let donorInfo = DonorInfo(declineReason: textView.text, donorStatus: .Declined)
        api().updateDonorInfo(donorInfo!)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type here (optional)..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    //MARK: - Support
    
    @IBOutlet weak var sendButton: UIButton!
    private let router : GiveBloodRouter
    @IBOutlet weak private var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
}
