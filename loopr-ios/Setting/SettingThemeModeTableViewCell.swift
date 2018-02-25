//
//  SettingThemeModeTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingThemeModeTableViewCell: UITableViewCell {

    @IBOutlet weak var nightModeSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if Themes.isNight() {
            nightModeSwitch.setOn(true, animated: false)
        } else {
            nightModeSwitch.setOn(false, animated: false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toggleNightModeSwitch(_ sender: Any) {
        if nightModeSwitch.isOn {
            print("toggleNightModeSwitch ON")
            Themes.switchTo(theme: .night)
        } else {
            print ("toggleNightModeSwitch OFF")
            Themes.switchTo(theme: .day)
        }
    }
    
    class func getCellIdentifier() -> String {
        return "SettingThemeModeTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }
}
