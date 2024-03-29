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
        
        getAllProduct()
    }
    
    
    var textLabel: UILabel = UILabel()
    
    var nonProductIds: [String] = []
    
    var blockCount: Int = 0
    
    
    var products: [SKProduct] = []
    var alwaysBuyProduct: [String] = []

    var buttons: [UIButton] = []
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "auto-renewing-subscription", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            nonProductIds = data as! [String]
            
            let _ = StoreObserver.default.request(products: Set(nonProductIds)) { [self] res in
                products = res
                
                for productIndex in 0..<products.count {
                    let button = UIButton.init(frame: CGRect(x: 35, y: 120 + 80 * (productIndex + 1), width: 300, height: 48))
                    
                    let product: SKProduct = products[productIndex]
                    var consCon = UIButton.Configuration.filled()
                    consCon.contentInsets = NSDirectionalEdgeInsets.zero
                    consCon.baseForegroundColor = UIColor.white
                    if (alwaysBuyProduct.contains(product.productIdentifier)) {
                        consCon.baseBackgroundColor = UIColor.orange
                    } else {
                        consCon.baseBackgroundColor = UIColor.red
                    }
                    consCon.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
                    consCon.buttonSize = .medium
                    button.configuration = consCon
                    button.tag = productIndex
                    button.setTitle(product.localizedTitle, for: .normal)
                    button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
                    
                    self.view.addSubview(button)
                    
                    buttons.append(button)
                }
            }
        
            updatePurshaseInfo()
        }
    }
    
    @objc func onClick(sender: UIButton) {
        Task {
            let product: SKProduct = products[sender.tag]
            
            let _ = StoreObserver.default.pay(product: product) { [self] in
                alwaysBuyProduct.append(product.productIdentifier)
                updatePurshaseInfo()
                sender.configuration?.baseBackgroundColor = UIColor.orange
            }
        }
    }
    
    func updatePurshaseInfo() {
        var p: [String] = []

        for product in products {
            if (alwaysBuyProduct.contains(product.productIdentifier)) {
                p.append(product.localizedTitle)
            }
        }
        self.textLabel.text = "已购内容：\n\(p.isEmpty ? "无" : p.joined(separator: "、"))";
    }
}
