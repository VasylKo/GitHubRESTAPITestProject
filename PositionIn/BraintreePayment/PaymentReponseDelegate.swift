//
//  PaymentProtocol.swift
//  PositionIn
//
//  Created by Max Stoliar on 1/11/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

protocol PaymentReponseDelegate {
    func paymentReponse(success: Bool, err: String?)
}
