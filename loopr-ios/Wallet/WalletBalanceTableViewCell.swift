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

    weak var delegate: WalletBalanceTableViewCellDelegate?

    @IBOutlet weak var balanceLabel: TickerLabel!
    @IBOutlet weak var hideAssetSwitch: UISwitch!
    @IBOutlet weak var hideAssetsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        balanceLabel.setFont(UIFont.init(name: FontConfigManager.shared.getRegular(), size: 27)!)
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor

        let balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balanceLabel.setText("\(balance)", animated: false)

        hideAssetSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        hideAssetSwitch.setOn(SettingDataManager.shared.getHideSmallAssets(), animated: false)

        self.theme_backgroundColor = GlobalPicker.backgroundColor
        
        hideAssetsLabel.theme_textColor = GlobalPicker.textColor
        hideAssetsLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)

        update()
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update() {
        balanceLabel.textColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
    }
    
    @objc func updateBalance() {
        let balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        if balance != balanceLabel.text {
            balanceLabel.setText(balance, animated: true)
            layoutIfNeeded()
        }
    }

    // The add button has been removed. However, we may still put it back in the future. Keep the code.
    @IBAction func pressAddButton(_ sender: Any) {
        print("pressAddButton")
        delegate?.navigatToAddAssetViewController()
    }

    @IBAction func toggleHideAssetSwitch(_ sender: Any) {
        if hideAssetSwitch.isOn {
            print("toggleHideAssetSwitch ON")
        } else {
            print ("toggleHideAssetSwitch OFF")
        }
        SettingDataManager.shared.setHideSmallAssets(hideAssetSwitch.isOn)
    }

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 150
    }
}
