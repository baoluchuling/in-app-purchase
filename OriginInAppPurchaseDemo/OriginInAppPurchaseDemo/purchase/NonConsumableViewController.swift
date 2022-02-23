//
//  NonConsumableViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import Foundation
import StoreKit

class NonConsumableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let allOrderButton = UIButton.init(frame: CGRect(x: 375 - 100 - 20, y: 80, width: 100, height: 30))
        
        allOrderButton.backgroundColor = UIColor.white
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets.zero
        configuration.baseForegroundColor = UIColor.systemBlue
        configuration.buttonSize = .medium
        allOrderButton.configuration = configuration
        allOrderButton.setTitle("全部订单", for: .normal)
        allOrderButton.addTarget(self, action: #selector(onAllOrderClick(sender:)), for: .touchUpInside)
        
        self.view.addSubview(allOrderButton)
        
        self.textLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        self.textLabel.text = "已购内容：--"
        self.textLabel.numberOfLines = 0
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
            guard let path = Bundle.main.url(forResource: "non-consumable", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
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
            
            for productIndex in 0..<nonProducts.count {
                let button = UIButton.init(frame: CGRect(x: 100, y: 120 + 80 * (productIndex + 1), width: 100, height: 48))
                
                let product: Product = nonProducts[productIndex]
                var consCon = UIButton.Configuration.filled()
                consCon.contentInsets = NSDirectionalEdgeInsets.zero
                consCon.baseForegroundColor = UIColor.white
                if (alwaysBuyProduct.contains(product.id)) {
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
            
            updatePurshaseInfo()
        }
    }
    
    @objc func onClick(sender: UIButton) {
        Task {
            let product: Product = nonProducts[sender.tag]
            
            // 已购买过的内容实际上也可以继续走购买流程，不会重复扣款
            
            // 这里只做测试性提示
            if (alwaysBuyProduct.contains(product.id)) {
                let alert: UIAlertController = UIAlertController(title: "内购", message: "该内容已购买，无需重复购买", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default))
                self.present(alert, animated: true)
                return
            }
            
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    
//                    await transaction.finish()
//
//                    alwaysBuyProduct.append(product.id)
//                    buttons[sender.tag].configuration?.baseBackgroundColor = UIColor.orange
//                    updatePurshaseInfo()
//
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
    
    func updatePurshaseInfo() {
        var p: [String] = []

        for product in nonProducts {
            if (alwaysBuyProduct.contains(product.id)) {
                p.append(product.displayName)
            }
        }
        self.textLabel.text = "已购内容：\n\(p.isEmpty ? "无" : p.joined(separator: "、"))";
    }
    
    @objc func onAllOrderClick(sender: UIButton) {
        self.navigationController?.pushViewController(AllOrderListViewController(), animated: true)
    }
}
