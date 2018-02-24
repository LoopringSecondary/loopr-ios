//
//  WalletBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol WalletBalanceTableViewCellDelegate {
    func navigatToAddAssetViewController()
}

class WalletBalanceTableViewCell: UITableViewCell {
    
    var balance = 1000.23
    var delegate: WalletBalanceTableViewCellDelegate?
    
    @IBOutlet weak var balanceLabel: TickerLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        balanceLabel.setText("\(balance)", animated: false)
        balanceLabel.setFont(UIFont.systemFont(ofSize: 36))
        balanceLabel.animationDuration = 0.5
        balanceLabel.textAlignment = NSTextAlignment.center;
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        // balanceLabel.text = "1000"
        // balanceLabel.setText("1999", animated: true)
    }
    
    @objc func updateBalance() {
        // Something cool
        // print("timer update")
        let decimal = Double(arc4random_uniform(100))
        balance = balance + Double(arc4random_uniform(100)) + decimal/100.0
        balanceLabel.setText("\(balance)", animated: true)
    }

    @IBAction func pressAddButton(_ sender: Any) {
        print("pressAddButton")
        delegate?.navigatToAddAssetViewController()
        // balanceLabel.setText("10090", animated: true)
        // balanceLabel.text = "10090"
    }
    
    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 160
    }
}
