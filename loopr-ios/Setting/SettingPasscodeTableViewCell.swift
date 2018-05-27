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
        
        passcodeLabel.text = NSLocalizedString("Night Mode", comment: "")
        passcodeLabel.font = FontConfigManager.shared.getLabelFont()
        
        passcodeSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        passcodeSwitch.setOn(SettingDataManager.shared.getPasscodeSetting(), animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func togglePasscodeSwitch(_ sender: Any) {
        if passcodeSwitch.isOn {
            print("togglePasscodeSwitch ON")
            
        } else {
            print ("togglePasscodeSwitch OFF")
        }
        
        SettingDataManager.shared.setPasscodeSetting(passcodeSwitch.isOn)
    }

    class func getCellIdentifier() -> String {
        return "SettingThemeModeTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }

}
