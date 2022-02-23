//
//  TransactionObserver.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import Foundation
import StoreKit

// 启动时调用
final class TransactionObserver {
    
    var updates: Task<Void, Never>? = nil
    
    init() {
        updates = Task {
            // 处理订单未完成的情况
            await processUnfinishedOrder()
            // 处理订单更新的情况
            await processUpdateOrder()
        }
    }
    
    func processUnfinishedOrder() async {
        for await verificationResult in Transaction.unfinished {
            guard case .verified(let transaction) = verificationResult else {
                continue
            }
            
            // 对于退款和上级的订单，直接进行关闭
            guard transaction.revocationDate == nil && !transaction.isUpgraded else {
                await transaction.finish()
                return
            }
            
            // 正常订单，和服务端进行验证
            // 服务端校验结果
            
            // 购买成功/购买失败关闭
            await transaction.finish()
        }
    }
    
    func processUpdateOrder() async {
        // 退款、过期、升级，只有非消耗型和订阅型才会触发这里，未finish的订单需要单独处理
        for await verificationResult in Transaction.updates {
            
            guard case .verified(let transaction) = verificationResult else {
                continue
            }
            
            print(transaction)
            
            if transaction.revocationDate != nil {
                // 　退款
                
            } else if let expirationDate = transaction.expirationDate,
                expirationDate < Date() {
                // 订阅过期
                await processUnfinishedOrder()
                continue
            } else if transaction.isUpgraded {
                
                continue
            } else {

            }
        }
    }

    deinit {
        updates?.cancel()
    }
}

