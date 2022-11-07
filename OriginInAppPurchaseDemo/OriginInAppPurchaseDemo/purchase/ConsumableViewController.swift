//
//  ConsumableViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import UIKit
import StoreKit

class ConsumableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.textLabel = UILabel(frame: CGRect(x: 100, y: 80, width: 200, height: 50))
        self.textLabel.text = "砖石数量：\(blockCount)";
        self.textLabel.textColor = UIColor.systemBlue
        self.view.addSubview(self.textLabel)
        
        getAllProduct()
    }
    
    var products: [SKProduct] = []
    
    var textLabel: UILabel = UILabel()
    
    var ownProducts: [String:Int] = [:]
    
    var blockCount: Int = 0
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "consumable", withExtension: "plist"), let data = NSDictionary.init(contentsOf: path) else {
                return
            }

            ownProducts = data as! [String:Int]
            
            let _ = StoreObserver.default.request(products: Set(ownProducts.keys)) { [self] res in
                products = res
                
                for productIndex in 0..<products.count {
                    let button = UIButton.init(frame: CGRect(x: 100, y: 120 + 80 * (productIndex + 1), width: 100, height: 36))
                    
                    let product: SKProduct = products[productIndex]
                    button.tag = productIndex
                    
                    var consCon = UIButton.Configuration.filled()
                    consCon.contentInsets = NSDirectionalEdgeInsets.zero
                    consCon.baseForegroundColor = UIColor.white
                    consCon.baseBackgroundColor = UIColor.red
                    consCon.buttonSize = .medium
                    button.configuration = consCon
                    button.setTitle(product.localizedTitle, for: .normal)
                    button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
                    
                    self.view.addSubview(button)
                }
            }
        }
    }
            
    @objc func onClick(sender: UIButton) {
        Task {
            
            let product: SKProduct = products[sender.tag]
            
            let _ = StoreObserver.default.pay(product: product) { [self] in
                blockCount += ownProducts[product.productIdentifier] ?? 0;
                self.textLabel.text = "砖石数量：\(blockCount)";
            }
        }
    }
    
    
}
