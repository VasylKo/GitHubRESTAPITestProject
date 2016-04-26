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
    var item: PurchaseConvertible
    private let promise: Promise<Void, NSError>
    
    // MARK: - Init, PaymentSystem
    required init(item: PurchaseConvertible) {
        self.item = item
        promise = Promise<Void, NSError>()
    }
    
    func purchase() -> Future<Void, NSError> {
        purchaseWithMPESA()
        return promise.future
    }
    
    private func purchaseWithMPESA() {
        switch item.purchaseType {
        case .Donation:
            purchaseDonation()
        case .Membership, .Eplus:
            purchaseMembership()
        case .Product:
            purchaseProduct()
        }
    }
    
    //MARK: - Purchase implementation
    private func purchaseDonation() {
        let response = api().donateCheckoutMpesa(String(item.totalAmount), nonce: "")
        commonMPESAPaymentPesponseHandler(response)
    }
    
    private func purchaseMembership() {
        let response = api().membershipCheckoutMpesa(String(item.totalAmount), nonce: "", membershipId: item.itemId ?? CRUDObjectInvalidId)
        commonMPESAPaymentPesponseHandler(response)
    }
        
    private func purchaseProduct() {
        let response = api().productCheckoutMpesa(item.price, nonce: "", itemId: item.itemId ?? CRUDObjectInvalidId, quantity: NSNumber(integer: item.quantity))
        commonMPESAPaymentPesponseHandler(response)
    }
    
    private func commonMPESAPaymentPesponseHandler(response: Future<String, NSError>) {
        response.onSuccess { [weak self] transactionId in
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