//
//  NonConsumableViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import Foundation
import StoreKit

class NonRenewingSubscriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.textLabel = UILabel(frame: CGRect(x: 100, y: 80, width: 200, height: 50))
        self.textLabel.text = "订阅内容：--";
        self.textLabel.textColor = UIColor.systemBlue
        self.view.addSubview(self.textLabel)
        
        getAllProduct()
    }
    
    
    var textLabel: UILabel = UILabel()
    
    var nonProductIds: [String] = []
    
    var blockCount: Int = 0
    
    
    var nonProducts: [Product] = []
    var alwaysBuyProduct: [String] = []

    var buttons: [UIButton] = []
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "non-renewing-subscription", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            nonProductIds = data as! [String]
            nonProducts = try await Product.products(for: nonProductIds)
                        
            for await verificationResult in Transaction.currentEntitlements {
                guard case .verified(let transaction) = verificationResult else {
                    continue
                }
                
                if transaction.revocationDate == nil {
                    alwaysBuyProduct.append(transaction.productID)
                }
            }
            
            
            var p: [String] = []

            for productIndex in 0..<nonProducts.count {
                let button = UIButton.init(frame: CGRect(x: 85, y: 120 + 80 * (productIndex + 1), width: 205, height: 48))
                
                let product: Product = nonProducts[productIndex]
                var consCon = UIButton.Configuration.filled()
                consCon.contentInsets = NSDirectionalEdgeInsets.zero
                consCon.baseForegroundColor = UIColor.white
                if (alwaysBuyProduct.contains(product.id)) {
                    p.append(product.displayName)
                    consCon.baseBackgroundColor = UIColor.orange
                } else {
                    consCon.baseBackgroundColor = UIColor.red
                }
                consCon.buttonSize = .medium
                button.configuration = consCon
                button.tag = productIndex
                button.setTitle(product.displayName, for: .normal)
                button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
                
                self.view.addSubview(button)
                
                buttons.append(button)
            }
            
            self.textLabel.text = "已购内容：\(p.isEmpty ? "无" : p.joined(separator: "、"))";
        }
    }
    
    @objc func onClick(sender: UIButton) {
        Task {
            let product: Product = nonProducts[sender.tag]
            
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    
                    await transaction.finish()
                    
                    alwaysBuyProduct.append(product.id)
                    buttons[sender.tag].configuration?.baseBackgroundColor = UIColor.orange
                    
                    break
                case .unverified(let transaction, let verificationError):
                    break
                }
                break
            case .pending:
                // The purchase requires action from the customer.
                // If the transaction completes,
                // it's available through Transaction.updates.
                break
            case .userCancelled:
                // The user canceled the purchase.
                break
            @unknown default:
                break
            }

        }
    }
}
