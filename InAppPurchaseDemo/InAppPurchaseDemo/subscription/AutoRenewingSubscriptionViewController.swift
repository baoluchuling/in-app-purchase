//
//  NonConsumableViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import Foundation
import StoreKit

// 自动订阅回调有问题，没法自动接收到，storekit2.0问题太多
class AutoRenewingSubscriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.textLabel = UILabel(frame: CGRect(x: 100, y: 80, width: 200, height: 50))
        self.textLabel.text = "已购内容：--";
        self.textLabel.textColor = UIColor.systemBlue
        self.view.addSubview(self.textLabel)
        
        let button = UIButton.init(frame: CGRect(x: 100, y: 80 + 50, width: 100, height: 48))
        
        var consCon = UIButton.Configuration.filled()
        consCon.contentInsets = NSDirectionalEdgeInsets.zero
        consCon.baseForegroundColor = UIColor.white
        consCon.baseBackgroundColor = UIColor.blue
        consCon.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        consCon.buttonSize = .medium
        button.configuration = consCon
        button.setTitle("退款", for: .normal)
        button.addTarget(self, action: #selector(onRefund(sender:)), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        getAllProduct()
    }
    
    
    var textLabel: UILabel = UILabel()
    
    var nonProductIds: [String] = []
    
    var blockCount: Int = 0
    
    
    var products: [Product] = []
    var alwaysBuyProduct: [Transaction] = []

    var buttons: [UIButton] = []
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "auto-renewing-subscription", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            nonProductIds = data as! [String]
            products = try await Product.products(for: nonProductIds)
            
            alwaysBuyProduct.removeAll()
                        
            for await verificationResult in Transaction.currentEntitlements {
                guard case .verified(let transaction) = verificationResult else {
                    continue
                }
                
                // 订阅已退款
                if (transaction.revocationDate != nil) {
                    continue
                }
                
                // 订阅已过期
                if (transaction.expirationDate != nil && transaction.expirationDate!.timeIntervalSince1970 <= Date.now.timeIntervalSince1970) {
                    continue
                }
                            
                alwaysBuyProduct.append(transaction)
            }
            
            buttons.removeAll()
            
            for productIndex in 0..<products.count {
                let button = UIButton.init(frame: CGRect(x: 35, y: 120 + 80 * (productIndex + 1), width: 300, height: 48))
                
                let product: Product = products[productIndex]
                var consCon = UIButton.Configuration.filled()
                consCon.contentInsets = NSDirectionalEdgeInsets.zero
                consCon.baseForegroundColor = UIColor.white
                if (alwaysBuyProduct.contains(where: { transaction in
                    transaction.productID == product.id
                })) {
                    consCon.baseBackgroundColor = UIColor.orange
                } else {
                    consCon.baseBackgroundColor = UIColor.red
                }
                consCon.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
                consCon.buttonSize = .medium
                button.configuration = consCon
                button.tag = productIndex
                button.setTitle(product.displayName, for: .normal)
                button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
                
                self.view.addSubview(button)
                
                buttons.append(button)
            }
            
            updatePurshaseInfo()
        }
    }
    
    @objc func onClick(sender: UIButton) {
        Task {
            let product: Product = products[sender.tag]
            
            let isEligible = await product.subscription?.isEligibleForIntroOffer
            
//            Product.SubscriptionInfo.isEligibleForIntroOffer(for: product.)
            
            print(product)
            
            // 对于有效期内的订阅再次购买，返回的是当前有效期内的商品transaction
            // 对于过期的商品订阅再次购买，返回的是新的商品transaction
            // 可以简单理解为，同一个一个订阅周期内相同商品只会有唯一一个transaction id
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    
                    print(transaction)
                    
                    await transaction.finish()
                    
                    getAllProduct()
                                        
                    break
                case .unverified(let transaction, let verificationError):
                    break
                }
                break
            case .pending:
                let alert: UIAlertController = UIAlertController(title: "内购", message: "购买中断", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default))
                self.present(alert, animated: true)
                break
            case .userCancelled:
                let alert: UIAlertController = UIAlertController(title: "内购", message: "用户取消", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default))
                self.present(alert, animated: true)
                break
            @unknown default:
                break
            }
        }
    }
    
    func updatePurshaseInfo() {
        var p: [String] = []

        for product in products {
            if (alwaysBuyProduct.contains(where: { transaction in
                transaction.productID == product.id
            })) {
                p.append(product.displayName)
            }
        }
        self.textLabel.text = "已购内容：\n\(p.isEmpty ? "无" : p.joined(separator: "、"))";
    }
    
    @objc func onRefund(sender: UIButton) {
        Task {
            
            let status = await try? alwaysBuyProduct.first?.beginRefundRequest(in: view.window!.windowScene!)
            
            print(status)
        }
    }
}
