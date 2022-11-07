//
//  StoreObserver.swift
//  OriginInAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/18.
//

import UIKit
import StoreKit


class PaymentHandler {
    var identifier: String?
    var closure: (() -> Void)?
    
    init(identifier: String? = nil, closure: (() -> Void)? = nil) {
        self.identifier = identifier
        self.closure = closure
    }
}

class RequestHandler {
    var identifier: String?
    var closure: (([SKProduct]) -> Void)?
    
    init(identifier: String? = nil, closure: (([SKProduct]) -> Void)? = nil) {
        self.identifier = identifier
        self.closure = closure
    }
}


class StoreObserver: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    static let `default` = StoreObserver()
    
    
    var paymentHandler: [PaymentHandler] = []
    var requestHandler: [RequestHandler] = []

    override init() {
        super.init()
    }

    // 支付结果 回调
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach { transaction in
            switch transaction.transactionState {
                case .purchasing:
                    break;
                case .purchased:
                    let id = String(transaction.payment.hash)
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                    paymentHandler.removeAll { handler in
                        let res = handler.identifier == id
                        if (res && handler.closure != nil) {
                            handler.closure!()
                        }
                        return res
                    }
                    
                    break;
                case .deferred:
                    break;
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    break;
                case .restored:
                    break;
                default:
                    break;
            }
        }
    }
    
    // 获取商品 回调
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        request.delegate = nil
        DispatchQueue.main.async { [self] in
            let id = String(request.hash)
            requestHandler.removeAll { handler in
                let res = handler.identifier == id
                if (res && handler.closure != nil) {
                    handler.closure!(response.products)
                }
                return res
            }
        }
    }
    
    func request(products: Set<String>, closure: @escaping ([SKProduct]) -> Void) {
            
        let productRequest = SKProductsRequest(productIdentifiers: products)
        productRequest.delegate = self
        productRequest.start()
        
        requestHandler.append(RequestHandler(identifier: String(productRequest.hash), closure: closure))
    }
    
    func pay(product: SKProduct, closure: @escaping () -> Void) -> String {
        let payment = SKMutablePayment(product: product)
        payment.quantity = 2
        
        paymentHandler.append(PaymentHandler(identifier: String(payment.hash), closure: closure))
        
        SKPaymentQueue.default().add(payment)
        
        return String(payment.hash)
    }
}
