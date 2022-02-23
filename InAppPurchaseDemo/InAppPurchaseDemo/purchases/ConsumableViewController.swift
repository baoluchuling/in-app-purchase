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
    
    var products: [Product] = []
    
    var textLabel: UILabel = UILabel()
    
    var ownProducts: [String:Int] = [:]
    
    var blockCount: Int = 0
    
    
    func getAllProduct() {
        
        Task {
            guard let path = Bundle.main.url(forResource: "consumable", withExtension: "plist"), let data = NSDictionary.init(contentsOf: path) else {
                return
            }

            ownProducts = data as! [String:Int]
            
            let productIdentifiers = Array(ownProducts.keys)
            products = try await Product.products(for: productIdentifiers)
                       
            for productIndex in 0..<products.count {
                let button = UIButton.init(frame: CGRect(x: 100, y: 120 + 80 * (productIndex + 1), width: 100, height: 36))
                
                let product: Product = products[productIndex]
                button.tag = productIndex
                
                var consCon = UIButton.Configuration.filled()
                consCon.contentInsets = NSDirectionalEdgeInsets.zero
                consCon.baseForegroundColor = UIColor.white
                consCon.baseBackgroundColor = UIColor.red
                consCon.buttonSize = .medium
                button.configuration = consCon
                button.setTitle(product.displayName, for: .normal)
                button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
                
                self.view.addSubview(button)
            }
        }
    }
    
    var unfinished = [Transaction]()
        
    @objc func onClick(sender: UIButton) {
        Task {
            
            // 如果有未完成订单，要在这里处理掉
            // 所有未finish的订单，在这里关闭掉，如果有自己的订单id，(出现在这里的订单都是已支付的)，需要在这里和服务端进行关联排查，并结束掉
            // 所以一般流程是在购买完成后，只有服务端确认已经在后端知道购买完成了，才能去关闭订单，不然的话，很容易出现已经付款，但是服务端未记录的丢单现象
            for await verificationResult in Transaction.unfinished {
                guard case .verified(let transaction) = verificationResult else {
                    continue
                }
                
                print(transaction)
                
                if !unfinished.contains(where: { $0.productID == transaction.productID }) {
                    unfinished.append(transaction)
                }
            }
            
            if !unfinished.isEmpty {
                let unfinishedCount = unfinished.count;
                let alert: UIAlertController = UIAlertController(title: "内购", message: "你有 \(unfinishedCount) 笔未完成订单，待处理", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("自动处理", comment: "Default action"), style: .default, handler: { [self] _ in
                    Task {
                        for transaction in self.unfinished {
                            await transaction.finish()
                        }

                        self.unfinished.removeAll()

                        let alert: UIAlertController = UIAlertController(title: "内购", message: "\(unfinishedCount) 笔订单已处理完毕", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                alert.dismiss(animated: true)
                            }
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("查看详情", comment: "Default action"), style: .default, handler: { [self] _ in
                    let c = OrderListViewController()
                    c.transactions = self.unfinished
                    self.navigationController?.pushViewController(c, animated: true)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("放弃", comment: "Default action"), style: .cancel))
                self.present(alert, animated: true)
                return;
            }
            
            let product: Product = products[sender.tag]
            
            do {
                let result: Product.PurchaseResult = try await product.purchase()
                
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                    
                        await transaction.finish()
                        
                        blockCount += ownProducts[transaction.productID] ?? 0;
                        
                        self.textLabel.text = "砖石数量：\(blockCount)";
                        
                        break
                    case .unverified(let transaction, let verificationError):
                        break
                    }
                    break
                case .pending:
                    // The purchase requires action from the customer.
                    // If the transaction completes,
                    // it's available through Transaction.updates.
                    
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
            } catch {
                
                var errorDesc = ""
                
                if error is StoreKitError {
                    switch error {
                    case StoreKitError.unknown:
                        errorDesc = "请稍后重试！"
                        break
                    case StoreKitError.userCancelled:
                        errorDesc = "用户已取消"
                        break
                    case StoreKitError.notAvailableInStorefront:
                        errorDesc = "该产品在当前店面中不可用"
                        break
                    case StoreKitError.networkError(let urlError):
                        errorDesc = "网络出现异常"
                        break
                    case StoreKitError.systemError(let sysError):
                        errorDesc = "请联系客服！"
                        break
                    default:
                        errorDesc = "请稍后重试！"
                        break
                    }
                } else if error is Product.PurchaseError {
                    switch error {
                    case Product.PurchaseError.invalidQuantity:
                        errorDesc = "无效数量"
                        break
                    case Product.PurchaseError.invalidOfferPrice:
                        errorDesc = "促销优惠价格无效"
                        break
                    case Product.PurchaseError.invalidOfferSignature:
                        errorDesc = "价格签名无效"
                        break
                    case Product.PurchaseError.invalidOfferIdentifier:
                        errorDesc = "购买选项中提供的促销优惠标识符无效"
                        break
                    case Product.PurchaseError.productUnavailable:
                        errorDesc = "该产品不可用"
                        break
                    case Product.PurchaseError.purchaseNotAllowed:
                        errorDesc = "不允许该用户进行购买"
                        break
                    case Product.PurchaseError.missingOfferParameters:
                        errorDesc = "缺少优惠参数"
                        break
                    default:
                        errorDesc = "请稍后重试！"
                        break
                    }
                    print( error.localizedDescription)
                } else {
                    errorDesc = "请稍后重试！"
                }
                
                let alert: UIAlertController = UIAlertController(title: "内购", message: "购买失败，\(errorDesc)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "Default action"), style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    
}
