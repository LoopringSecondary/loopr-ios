//
//  WalletBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol WalletBalanceTableViewCellDelegate: class {
    func navigatToAddAssetViewController()
}

class WalletBalanceTableViewCell: UITableViewCell {
    
    var balance = 1000.23
    weak var delegate: WalletBalanceTableViewCellDelegate?
    
    @IBOutlet weak var balanceLabel: TickerLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        balanceLabel.setText("\(balance)", animated: false)
        balanceLabel.setFont(UIFont.systemFont(ofSize: 36))
        balanceLabel.animationDuration = 0.5
        balanceLabel.textAlignment = NSTextAlignment.center
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        
    }
    
    @objc func updateBalance() {
        let decimal = Double(arc4random_uniform(100))
        balance += Double(arc4random_uniform(100)) + decimal/100.0
        balanceLabel.setText("\(balance)", animated: true)
    }

    // The add button has been removed. However, we may still put it back in the future. Keep the code.
    @IBAction func pressAddButton(_ sender: Any) {
        print("pressAddButton")
        delegate?.navigatToAddAssetViewController()
    }
    
    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 160
    }
}
