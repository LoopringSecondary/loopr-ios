//
//  SettingPasscodeTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/26/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingPasscodeTableViewCell: UITableViewCell {

    @IBOutlet weak var passcodeLabel: UILabel!
    @IBOutlet weak var passcodeSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        passcodeLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        passcodeLabel.textColor = Themes.isDark() ? UIColor.white : UIColor.dark2
        backgroundColor = Themes.isDark() ? UIColor.dark2 : UIColor.white
        
        passcodeLabel.text = BiometricType.get().description
        
        passcodeSwitch.transform = CGAffineTransform(scaleX: 0.77, y: 0.77)
        passcodeSwitch.setOn(AuthenticationDataManager.shared.getPasscodeSetting(), animated: false)
    }
    
    @IBAction func togglePasscodeSwitch(_ sender: Any) {
        AuthenticationDataManager.shared.setPasscodeSetting(passcodeSwitch.isOn)
    }

    class func getCellIdentifier() -> String {
        return "SettingThemeModeTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }

}
