//
//  UpdatedSelectWalletTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class UpdatedSelectWalletTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var toatalBalanceLabel: UILabel!

    var wallet: AppWallet?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        baseView.layer.borderWidth = 1
        baseView.layer.cornerRadius = 7.5
        nameLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 14)
        addressLabel.font = FontConfigManager.shared.getRegularFont(size: 11)
        addressLabel.lineBreakMode = .byTruncatingMiddle
        toatalBalanceLabel.font = FontConfigManager.shared.getRegularFont(size: 12)

        setNoCurrentWallet()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        print("hightlighted: \(highlighted)")
        if highlighted {
            print("change color")
            if wallet!.address == CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address {
                // baseView.backgroundColor = UIColor.init(rgba: "#2E2BA4").withAlphaComponent(0.7)
            } else {
                baseView.layer.borderColor = UIColor.clear.cgColor
                baseView.backgroundColor = UIColor.init(rgba: "#2E2BA4").withAlphaComponent(0.7)
            }
        } else {
            print("reset color")
            update()
        }
    }

    func update() {
        if let wallet = wallet {
            nameLabel.text = wallet.name
            addressLabel.text = wallet.address.getAddressFormat()
            toatalBalanceLabel.text = wallet.totalCurrency.currency
            setNoCurrentWallet()
            
            if wallet.address == CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address {
                setCurrentWallet()
            } else {
                setNoCurrentWallet()
            }
        }
    }
    
    func setNoCurrentWallet() {
        baseView.backgroundColor = UIColor.white
        baseView.layer.borderColor = UIColor.init(rgba: "#E5E7ED").cgColor
        nameLabel.textColor = UIColor.init(rgba: "#32384C")
        addressLabel.textColor = UIColor.init(rgba: "#8997F3")
        toatalBalanceLabel.textColor = UIColor.init(rgba: "#32384C")
    }
    
    func setCurrentWallet() {
        baseView.backgroundColor = UIColor.init(rgba: "#2E2BA4")
        baseView.layer.borderColor = UIColor.clear.cgColor
        nameLabel.textColor = UIColor.white
        addressLabel.textColor = UIColor.init(rgba: "#8997F3")
        toatalBalanceLabel.textColor = UIColor.white
    }
    
    class func getCellIdentifier() -> String {
        return "UpdatedSelectWalletTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 80
    }
}
