//
//  WalletButtonTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol WalletButtonTableViewCellDelegate: class {
    func navigationToScanViewController()
    func navigationToReceiveViewController()
    func navigationToSendViewController()
    func navigationToTradeViewController()
}

class WalletButtonTableViewCell: UITableViewCell {

    weak var delegate: WalletButtonTableViewCellDelegate?
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var buttonHeightLayoutConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        self.theme_backgroundColor = ColorPicker.backgroundColor
        let iconTitlePadding: CGFloat = 14
        
        button1.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        button1.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        button1.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button1.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button1.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button1.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        button1.set(image: UIImage.init(named: "Scan-dark"), title: LocalizedString("Scan", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button1.set(image: UIImage.init(named: "Scan-dark")?.alpha(0.6), title: LocalizedString("Scan", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button2.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        button2.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        button2.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button2.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button2.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button2.addTarget(self, action: #selector(self.pressedButton2(_:)), for: .touchUpInside)
        button2.set(image: UIImage.init(named: "Transaction-receive-dark"), title: LocalizedString("Receive", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button2.set(image: UIImage.init(named: "Transaction-receive-dark")?.alpha(0.6), title: LocalizedString("Receive", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button3.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        button3.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        button3.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button3.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button3.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button3.addTarget(self, action: #selector(self.pressedButton3(_:)), for: .touchUpInside)
        button3.set(image: UIImage.init(named: "Transaction-send-dark"), title: LocalizedString("Send", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button3.set(image: UIImage.init(named: "Transaction-send-dark")?.alpha(0.6), title: LocalizedString("Send", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button4.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
        button4.titleLabel?.theme_textColor = GlobalPicker.textLightColor
        button4.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button4.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button4.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button4.addTarget(self, action: #selector(self.pressedButton4(_:)), for: .touchUpInside)
        button4.set(image: UIImage.init(named: "Transaction-sell-dark"), title: "P2P", titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button4.set(image: UIImage.init(named: "Transaction-sell-dark")?.alpha(0.6), title: "P2P", titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        buttonHeightLayoutConstraint.constant = WalletButtonTableViewCell.getButtonHeight()
    }
    
    @objc func pressedButton1(_ button: UIButton) {
        print("pressedItem1Button")
        delegate?.navigationToScanViewController()
    }
    
    @objc func pressedButton2(_ button: UIButton) {
        print("pressedItem2Button")
        delegate?.navigationToReceiveViewController()
    }
    
    @objc func pressedButton3(_ button: UIButton) {
        print("pressedItem3Button")
        delegate?.navigationToSendViewController()
    }
    
    @objc func pressedButton4(_ button: UIButton) {
        print("pressedItem4Button")
        delegate?.navigationToTradeViewController()
    }

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    private class func getButtonHeight() -> CGFloat {
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let buttonHeight = (screenWidth - 15*2 - 10*3)/4.0
        return buttonHeight
    }
    
    class func getHeight() -> CGFloat {
        // Top padding: 4px. Bottom padding: 12px.
        return getButtonHeight() + 4 + 12
    }

}
