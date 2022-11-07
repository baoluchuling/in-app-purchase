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
    
    var productIds: [String] = []
    
    var products: [SKProduct] = []
    var alwaysBuyProduct: [String] = []

    var buttons: [UIButton] = []
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "non-consumable", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            productIds = data as! [String]
            
            StoreObserver.default.alwaysBuy()
            
//            let _ = StoreObserver.default.request(products: Set(productIds)) { [self] res in
//                products = res
//
//                for productIndex in 0..<products.count {
//                    let button = UIButton.init(frame: CGRect(x: 100, y: 120 + 80 * (productIndex + 1), width: 100, height: 48))
//
//                    let product: SKProduct = products[productIndex]
//                    var consCon = UIButton.Configuration.filled()
//                    consCon.contentInsets = NSDirectionalEdgeInsets.zero
//                    consCon.baseForegroundColor = UIColor.white
//                    if (alwaysBuyProduct.contains(product.productIdentifier)) {
//                        consCon.baseBackgroundColor = UIColor.orange
//                    } else {
//                        consCon.baseBackgroundColor = UIColor.red
//                    }
//                    consCon.buttonSize = .medium
//                    button.configuration = consCon
//                    button.tag = productIndex
//                    button.setTitle(product.localizedTitle, for: .normal)
//                    button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
//
//                    self.view.addSubview(button)
//
//                    buttons.append(button)
//                }
//            }
            
            
            
            updatePurshaseInfo()
        }
    }
    
    @objc func onClick(sender: UIButton) {
        Task {
            let product: SKProduct = products[sender.tag]
            
            // 已购买过的内容实际上也可以继续走购买流程，不会重复扣款
            
            // 这里只做测试性提示
            if (alwaysBuyProduct.contains(product.productIdentifier)) {
                let alert: UIAlertController = UIAlertController(title: "内购", message: "该内容已购买，无需重复购买", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default))
                self.present(alert, animated: true)
                return
            }
                        
            let _ = StoreObserver.default.pay(product: product) { [self] in
                alwaysBuyProduct.append(product.productIdentifier)
                updatePurshaseInfo()
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
    
    @objc func onAllOrderClick(sender: UIButton) {
        self.navigationController?.pushViewController(AllOrderListViewController(), animated: true)
    }
}
