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
        
        mnemonicLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 14)
        mnemonicLabel.textAlignment = .center
        mnemonicLabel.clipsToBounds = true
        mnemonicLabel.backgroundColor = Themes.isDark() ? UIColor.dark3 : UIColor.white
    }

    class func getCellIdentifier() -> String {
        return "MnemonicBackupModeCollectionViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 47
    }
}
