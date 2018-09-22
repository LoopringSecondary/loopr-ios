//
//  MnemonicCollectionViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mnemonicLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mnemonicLabel.layer.cornerRadius = 2
        mnemonicLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        mnemonicLabel.textColor = .white
    }

    class func getCellIdentifier() -> String {
        return "MnemonicCollectionViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 32
    }

}
