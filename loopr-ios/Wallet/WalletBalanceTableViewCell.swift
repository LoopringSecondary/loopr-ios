//
//  WalletBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol WalletBalanceTableViewCellDelegate: class {
    func pressedQACodeButtonInWalletBalanceTableViewCell()
}

class WalletBalanceTableViewCell: UITableViewCell {

    weak var delegate: WalletBalanceTableViewCellDelegate?

    var updateBalanceLabelTimer: Timer?
    var baseView: UIImageView = UIImageView()
    let balanceLabel: TickerLabel = TickerLabel()
    let addressLabel: UILabel = UILabel()
    let qrCodeButton: UIButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor

        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseView.frame = CGRect(x: 15, y: 10, width: screenWidth - 15*2, height: 120)
        baseView.image = UIImage(named: "wallet-background" + ColorTheme.getTheme())
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
        addressLabel.setSubTitleDigitFont()
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingMiddle
        addSubview(addressLabel)
        
        qrCodeButton.frame = CGRect(x: addressLabel.frame.maxX, y: addressLabel.frame.minY + (addressLabel.frame.height-30)*0.5, width: 30, height: 30)
        qrCodeButton.setImage(UIImage(named: "QRCode-white"), for: .normal)
        qrCodeButton.addTarget(self, action: #selector(self.pressedQRCodeButton(_:)), for: .touchUpInside)
        addSubview(qrCodeButton)
        
        if updateBalanceLabelTimer == nil {
            //  Disable due to socket io is also disabled.
            // updateBalanceLabelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
        }
        update()
    }

    private func update() {
        balanceLabel.textColor = UIColor.white
        addressLabel.theme_textColor = GlobalPicker.textLightColor
    }
    
    func setup(animated: Bool) {
        addressLabel.text = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address ?? ""
        var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balance.insert(" ", at: balance.index(after: balance.startIndex))
        balanceLabel.setText(balance, animated: animated)
        balanceLabel.layoutCharacterLabels()
    }
    
    @objc func updateBalance() {
        balanceLabel.textColor = UIColor.white
        var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
        balance.insert(" ", at: balance.index(after: balance.startIndex))
        balanceLabel.setText(balance, animated: true)
        layoutIfNeeded()
    }
    
    func startUpdateBalanceLabelTimer() {
        if updateBalanceLabelTimer == nil {
            //  Disable due to socket io is also disabled.
            // updateBalanceLabelTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateBalance), userInfo: nil, repeats: true)
        }
    }

    func stopUpdateBalanceLabelTimer() {
        if updateBalanceLabelTimer != nil {
            updateBalanceLabelTimer?.invalidate()
            updateBalanceLabelTimer = nil
        }
    }
    
    @objc func pressedQRCodeButton(_ button: UIButton) {
        print("pressedItem1Button")
        delegate?.pressedQACodeButtonInWalletBalanceTableViewCell()
    }

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 134
    }
}
