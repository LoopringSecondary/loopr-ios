//
//  WalletBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol WalletBalanceTableViewCellDelegate: class {
    func updateTableView(isHideSmallAsset: Bool)
}

class WalletBalanceTableViewCell: UITableViewCell {

    weak var delegate: WalletBalanceTableViewCellDelegate?

    var updateBalanceLabelTimer: Timer?

    @IBOutlet weak var hideAssetsView: UIView!
    @IBOutlet weak var balanceLabel: TickerLabel!
    @IBOutlet weak var hideAssetSwitch: UISwitch!
    @IBOutlet weak var hideAssetsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Hide the hideAssetsView
        hideAssetsView.isHidden = true

        balanceLabel.setFont(FontConfigManager.shared.getRegularFont(size: 27))
        balanceLabel.animationDuration = 0.3
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor

        let balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balanceLabel.setText("\(balance)", animated: false)

        hideAssetSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        hideAssetSwitch.setOn(SettingDataManager.shared.getHideSmallAssets(), animated: false)

        self.theme_backgroundColor = GlobalPicker.backgroundColor
        
        hideAssetsLabel.theme_textColor = GlobalPicker.textColor
        hideAssetsLabel.text = NSLocalizedString("Hide Small Assets", comment: "")
        hideAssetsLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14*UIStyleConfig.scale)

        update()
        if updateBalanceLabelTimer == nil {
            updateBalanceLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
        }
    }

    func update() {
        balanceLabel.textColor = Themes.isNight() ? UIColor.white : UIColor.black
    }
    
    func setup() {
        let balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balanceLabel.setText(balance, animated: true)
        balanceLabel.layoutCharacterLabels()
    }
    
    @objc func updateBalance() {
        let balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        print(balance)
        balanceLabel.setText(balance, animated: true)
        layoutIfNeeded()
    }
    
    func startUpdateBalanceLabelTimer() {
        if updateBalanceLabelTimer == nil {
            updateBalanceLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
        }
    }

    func stopUpdateBalanceLabelTimer() {
        if updateBalanceLabelTimer != nil {
            updateBalanceLabelTimer?.invalidate()
            updateBalanceLabelTimer = nil
        }
    }

    @IBAction func toggleHideAssetSwitch(_ sender: Any) {
        if hideAssetSwitch.isOn {
            print("toggleHideAssetSwitch ON")
        } else {
            print ("toggleHideAssetSwitch OFF")
        }
        SettingDataManager.shared.setHideSmallAssets(hideAssetSwitch.isOn)
        delegate?.updateTableView(isHideSmallAsset: hideAssetSwitch.isOn)
    }

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        // TODO: 
        // return 150*UIStyleConfig.scale
        return 150 - 42 + 20
    }
}
