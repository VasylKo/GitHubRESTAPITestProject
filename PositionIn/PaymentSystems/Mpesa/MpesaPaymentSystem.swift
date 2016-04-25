//
//  MpesaPaymentSystem.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 25/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures


final class MpesaPaymentSystem: PaymentSystem {

    // MARK: - Private ivar
    private var item: PurchaseConvertible
    private let promise: Promise<Void, NSError>
    
    // MARK: - Init, PaymentSystem
    required init(item: PurchaseConvertible) {
        self.item = item
        promise = Promise<Void, NSError>()
    }
    
    func purchase() -> Future<Void, NSError> {
        payDonationWithMPESA()
        return promise.future
    }
    
    //MARK: - MPESA Payment
    private func payDonationWithMPESA() {
        api().donateCheckoutMpesa(String(item.totalAmount), nonce: "").onSuccess { [weak self] transactionId in
            guard let strongSelf = self else { return }
            strongSelf.pollStatus(transactionId)
            
            }.onFailure() { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.promise.failure(error)
        }
    }
    

@objc func pollStatus(transactionId: String) {
    api().transactionStatusMpesa(transactionId).onSuccess{ [weak self] status in
        guard let strongSelf = self else { return }
        strongSelf.promise.success()
        }.onFailure { [weak self] error in
            guard let strongSelf = self else { return }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                strongSelf.pollStatus(transactionId)
            }
        }
    }
}