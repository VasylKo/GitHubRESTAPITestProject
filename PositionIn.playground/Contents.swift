//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import PosInCore


XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0))
containerView.backgroundColor = UIColor.blueColor()
XCPShowView("Container View", containerView)

let p = NetworkDataProvider()


