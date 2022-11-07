//
//  OrderListViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import UIKit
import StoreKit

class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var transactions: [Transaction] = []
    var products: [Product] = []

    var tableview: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        
        self.tableview = UITableView(frame: CGRect(x: 0, y: 0, width: 375, height: 814))
        self.tableview?.delegate = self;
        self.tableview?.dataSource = self;
        
        self.tableview?.estimatedRowHeight = 50
        
        self.tableview?.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        
        self.view.addSubview(self.tableview!)
        
        Task {
            
            guard let path = Bundle.main.url(forResource: "consumable", withExtension: "plist"), let data = NSDictionary.init(contentsOf: path) else {
                return
            }

            let pids = Array((data as! [String:Int]).keys)
            products = (try? await Product.products(for: pids)) ?? []
            
            guard let path = Bundle.main.url(forResource: "non-consumable", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            let nonpids = data as! [String]
            products += ((try? await Product.products(for: nonpids)) ?? [])
            
            guard let path = Bundle.main.url(forResource: "non-renewing-subscription", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            let subpids = data as! [String]
            products += ((try? await Product.products(for: subpids)) ?? [])
            
            guard let path = Bundle.main.url(forResource: "auto-renewing-subscription", withExtension: "plist"), let data = NSArray.init(contentsOf: path) else {
                return
            }

            let autosubpids = data as! [String]
            products += ((try? await Product.products(for: autosubpids)) ?? [])
            
            for await verificationResult in Transaction.unfinished {
                guard case .verified(let transaction) = verificationResult else {
                    continue
                }
                
                print(transaction)
                
                self.transactions.append(transaction)
            }
            
            self.tableview?.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let transaction: Transaction = self.transactions[indexPath.row]
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = .none
        cell.setupData(
            title: "\(products.first(where: { $0.id == transaction.productID })?.displayName ?? "未知")",
            num: "\(transaction.id)",
            price: "\(products.first(where: { $0.id == transaction.productID })?.displayPrice ?? "未知")",
            date: transaction.purchaseDate.ISO8601Format(),
            isRefund: transaction.revocationDate != nil
        )
        
        return cell
    }
}

class CustomTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel?
    var numLabel: UILabel?
    var priceLabel: UILabel?
    var dateLabel: UILabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor.white
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }

        self.titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 200, height: 30))
        self.titleLabel?.backgroundColor = UIColor.white
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel?.textColor = UIColor.black
        
        self.contentView.addSubview(self.titleLabel!)
        
        self.numLabel = UILabel(frame: CGRect(x: 20, y: 10 + 30 + 5, width: 100, height: 15))
        self.numLabel?.font = UIFont.systemFont(ofSize: 11)
        self.numLabel?.textColor = UIColor.gray
        self.numLabel?.backgroundColor = UIColor.white
        
        self.contentView.addSubview(self.numLabel!)
        
        self.priceLabel = UILabel(frame: CGRect(x: 375 - 100 - 20, y: 10, width: 100, height: 30))
        self.priceLabel?.font = UIFont.systemFont(ofSize: 14)
        self.priceLabel?.textColor = UIColor.systemRed
        self.priceLabel?.textAlignment = .right
        self.priceLabel?.backgroundColor = UIColor.white

        self.contentView.addSubview(self.priceLabel!)
        
        self.dateLabel = UILabel(frame: CGRect(x: 375 - 150 - 20, y: 10 + 30, width: 150, height: 20))
        self.dateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.dateLabel?.textColor = UIColor.black
        self.dateLabel?.textAlignment = .right
        self.dateLabel?.backgroundColor = UIColor.white

        self.contentView.addSubview(self.dateLabel!)
    }
    
    func setupData(title: String?, num: String?, price: String?, date: String?, isRefund: Bool) {
        self.titleLabel?.text = title
        self.numLabel?.text = num
        self.dateLabel?.text = date
        
        if isRefund {
            self.priceLabel?.text = "+\(price ?? "")"
            self.priceLabel?.textColor = UIColor.systemRed
        } else {
            self.priceLabel?.text = "-\(price ?? "")"
            self.priceLabel?.textColor = UIColor.systemGreen
        }
    }
}
