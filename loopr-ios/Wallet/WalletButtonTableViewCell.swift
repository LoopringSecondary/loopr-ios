//
//  WalletButtonTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        self.theme_backgroundColor = GlobalPicker.tableViewBackgroundColor
        
        let iconTitlePadding: CGFloat = 14
        
        button1.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        button1.setTitleColor(UIColor.init(rgba: "#fff"), for: .normal)
        // button1.setTitleColor(UIColor.init(white: 0, alpha: 0.6), for: .highlighted)
        button1.setBackgroundColor(UIColor.black, for: .normal)
        button1.setBackgroundColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        button1.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        
        button1.set(image: UIImage.init(named: "Scan-white"), title: LocalizedString("Scan", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button1.set(image: UIImage.init(named: "Scan-white")?.alpha(0.6), title: LocalizedString("Scan", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button2.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        button2.setTitleColor(UIColor.init(rgba: "#fff"), for: .normal)
        // button1.setTitleColor(UIColor.init(white: 0, alpha: 0.6), for: .highlighted)
        button2.setBackgroundColor(UIColor.black, for: .normal)
        button2.setBackgroundColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        button2.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        
        button2.set(image: UIImage.init(named: "Received-white"), title: LocalizedString("Receive", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button2.set(image: UIImage.init(named: "Received-white")?.alpha(0.6), title: LocalizedString("Receive", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button3.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        button3.setTitleColor(UIColor.init(rgba: "#fff"), for: .normal)
        // button1.setTitleColor(UIColor.init(white: 0, alpha: 0.6), for: .highlighted)
        button3.setBackgroundColor(UIColor.black, for: .normal)
        button3.setBackgroundColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        button3.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        
        button3.set(image: UIImage.init(named: "Scan-white"), title: LocalizedString("Send", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button3.set(image: UIImage.init(named: "Scan-white")?.alpha(0.6), title: LocalizedString("Send", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button4.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        button4.setTitleColor(UIColor.init(rgba: "#fff"), for: .normal)
        // button1.setTitleColor(UIColor.init(white: 0, alpha: 0.6), for: .highlighted)
        button4.setBackgroundColor(UIColor.black, for: .normal)
        button4.setBackgroundColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        button4.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        
        button4.set(image: UIImage.init(named: "Scan-white"), title: LocalizedString("Trade", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button4.set(image: UIImage.init(named: "Scan-white")?.alpha(0.6), title: LocalizedString("Trade", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
    }
    
    @objc func pressedButton1(_ button: UIButton) {
        print("pressedItem1Button")
    }

    class func getCellIdentifier() -> String {
        return "WalletBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }

}
