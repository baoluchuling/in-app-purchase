//
//  ViewController.swift
//  OriginInAppPurchaseDemo
//
//  Created by baoluchuling on 2022/2/18.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let consumableButton = UIButton.init(frame: CGRect(x: 100, y: 150, width: 200, height: 50))
        var consCon = UIButton.Configuration.filled()
        consCon.contentInsets = NSDirectionalEdgeInsets.zero
        consCon.baseForegroundColor = UIColor.white
        consCon.baseBackgroundColor = UIColor.systemBlue
        consCon.buttonSize = .medium
        consumableButton.configuration = consCon
        consumableButton.setTitle("消耗性商品", for: .normal)
        consumableButton.addTarget(self, action: #selector(onConsumableClick(sender:)), for: .touchUpInside)
        
        self.view.addSubview(consumableButton)
        
        let nonConsumableButton = UIButton.init(frame: CGRect(x: 100, y: 150 + 100, width: 200, height: 50))
        
        var nonconsCon = UIButton.Configuration.filled()
        nonconsCon.contentInsets = NSDirectionalEdgeInsets.zero
        nonconsCon.baseForegroundColor = UIColor.white
        nonconsCon.baseBackgroundColor = UIColor.systemBlue
        nonconsCon.buttonSize = .medium
        nonConsumableButton.configuration = nonconsCon
        nonConsumableButton.setTitle("非消耗性商品", for: .normal)
        nonConsumableButton.addTarget(self, action: #selector(onNonConsumableClick(sender:)), for: .touchUpInside)
        
        self.view.addSubview(nonConsumableButton)
        
        let nonRenewingButton = UIButton.init(frame: CGRect(x: 100, y: 150 + 100 + 100, width: 200, height: 50))
        var nonRenewingCon = UIButton.Configuration.filled()
        nonRenewingCon.contentInsets = NSDirectionalEdgeInsets.zero
        nonRenewingCon.baseForegroundColor = UIColor.white
        nonRenewingCon.baseBackgroundColor = UIColor.systemPink
        nonRenewingCon.buttonSize = .medium
        nonRenewingButton.configuration = nonRenewingCon
        nonRenewingButton.setTitle("非续订型订阅商品", for: .normal)
        nonRenewingButton.addTarget(self, action: #selector(onNonRenewingClick(sender:)), for: .touchUpInside)
        
        self.view.addSubview(nonRenewingButton)
        
        let autoRenewingButton = UIButton.init(frame: CGRect(x: 100, y: 150 + 100 + 100 + 100, width: 200, height: 50))
        var autoRenewingCon = UIButton.Configuration.filled()
        autoRenewingCon.contentInsets = NSDirectionalEdgeInsets.zero
        autoRenewingCon.baseForegroundColor = UIColor.white
        autoRenewingCon.baseBackgroundColor = UIColor.systemPink
        autoRenewingCon.buttonSize = .medium
        autoRenewingButton.configuration = autoRenewingCon
        autoRenewingButton.setTitle("自动续订型订阅商品", for: .normal)
        autoRenewingButton.addTarget(self, action: #selector(onAutoRenewingClick(sender:)), for: .touchUpInside)
        
        self.view.addSubview(autoRenewingButton)
    }
    
    //
    @objc func onConsumableClick(sender: UIButton) {
        self.navigationController?.pushViewController(ConsumableViewController(), animated: true)
    }
    
    @objc func onNonConsumableClick(sender: UIButton) {
        self.navigationController?.pushViewController(NonConsumableViewController(), animated: true)
    }
    
    @objc func onNonRenewingClick(sender: UIButton) {
        self.navigationController?.pushViewController(NonRenewingSubscriptionViewController(), animated: true)
    }
    
    @objc func onAutoRenewingClick(sender: UIButton) {
        self.navigationController?.pushViewController(AutoRenewingSubscriptionViewController(), animated: true)
    }
}

