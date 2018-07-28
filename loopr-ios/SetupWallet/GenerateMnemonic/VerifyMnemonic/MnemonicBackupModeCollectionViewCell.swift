//
//  MnemonicBackupModeCollectionViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicBackupModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mnemonicLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mnemonicLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        mnemonicLabel.textAlignment = .center
        mnemonicLabel.textColor = Themes.isDark() ? UIColor.white : UIColor.dark3

        cornerRadius = 6
        clipsToBounds = true
        backgroundColor = Themes.isDark() ? UIColor.dark3 : UIColor.white
    }

    class func getCellIdentifier() -> String {
        return "MnemonicBackupModeCollectionViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 44
    }
}
