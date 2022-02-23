//
//  StoreObserver.swift
//  OriginInAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/18.
//

import UIKit
import StoreKit

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    
    static let `default` = StoreObserver()

    override init() {
        super.init()
    }

    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}
