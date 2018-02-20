//
//  WalletBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import EFCountingLabel

protocol WalletBalanceTableViewCellDelegate {
    func navigatToAddAssetViewController()
}

class WalletBalanceTableViewCell: UITableViewCell {
    
    var delegate: WalletBalanceTableViewCellDelegate?

    @IBOutlet weak var totalBalanceLabel: EFCountingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        totalBalanceLabel.countFrom(1, to: 10, withDuration: 3.0)
    }

    @IBAction func pressAddButton(_ sender: Any) {
        delegate?.navigatToAddAssetViewController()
    }
    
    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 160
    }
}
