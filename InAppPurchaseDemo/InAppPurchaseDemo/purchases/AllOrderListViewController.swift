//
//  AllOrderListViewController.swift
//  InAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/15.
//

import UIKit
import StoreKit

class AllOrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var transactions: [Transaction] = []
    
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
        
        fetchAllOrder()
    }
    
    var products: [Product] = []

    func fetchAllOrder() {
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
            
            for await verificationResult in Transaction.all {
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
        
        print(transaction)
        
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
