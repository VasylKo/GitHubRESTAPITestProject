//
// Created by Max Stoliar on 1/17/16.
// Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MpesaViewController : UIViewController, PaymentProtocol {
    var amount: Int?
    var quantity: Int?
    var productName: String?
    var delegate: PaymentReponseDelegate?
}
