//
//  PaymentProtocol.swift
//  PositionIn
//
//  Created by Max Stoliar on 1/11/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//


protocol PaymentProtocol {
    var amount: Int? { get set }
    var itemId: String? { get set }
    var quantity: Int? { get set }
    var productName: String? { get set }
    var delegate: PaymentReponseDelegate? { get set }
    var product: Product? { get set }
}

protocol PaymentReponseDelegate {
    func paymentReponse(success: Bool, err: String?)
}