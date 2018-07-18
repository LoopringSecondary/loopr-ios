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
    var baseView: UIImageView = UIImageView()
    let balanceLabel: TickerLabel = TickerLabel()
    let addressLabel: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        self.theme_backgroundColor = GlobalPicker.tableViewBackgroundColor
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseView.frame = CGRect(x: 10, y: 10, width: screenWidth - 20, height: 160 - 20)
        baseView.image = UIImage(named: "Header-background")
        baseView.contentMode = .scaleToFill
        addSubview(baseView)
        
        balanceLabel.frame = CGRect(x: 10, y: 40, width: screenWidth - 20, height: 36)
        balanceLabel.setFont(FontConfigManager.shared.getMediumFont(size: 32))
        balanceLabel.animationDuration = 0.3
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()

        var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balance.insert(" ", at: balance.index(after: balance.startIndex))
        balanceLabel.setText("\(balance)", animated: false)
        addSubview(balanceLabel)

        addressLabel.frame = CGRect(x: screenWidth*0.25, y: balanceLabel.frame.maxY, width: screenWidth*0.5, height: 30)
        addressLabel.setSubTitleFont()
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingMiddle
        addressLabel.text = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address ?? ""
        addSubview(addressLabel)
        
        if updateBalanceLabelTimer == nil {
            updateBalanceLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
        }
        update()
    }

    private func update() {
        balanceLabel.textColor = Themes.isDark() ? UIColor.white : UIColor.black
        addressLabel.theme_textColor = GlobalPicker.textLightColor
    }
    
    func setup() {
        var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balance.insert(" ", at: balance.index(after: balance.startIndex))
        balanceLabel.setText(balance, animated: true)
        balanceLabel.layoutCharacterLabels()
    }
    
    @objc func updateBalance() {
        var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balance.insert(" ", at: balance.index(after: balance.startIndex))
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

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 150
    }
}
