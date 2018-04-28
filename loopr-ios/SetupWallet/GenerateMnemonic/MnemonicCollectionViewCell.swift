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
    
    // TODO: seperate the circle and the label
    @IBOutlet weak var circleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        circleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 12)
        circleLabel.textAlignment = .center
        circleLabel.layer.cornerRadius = 20.0 * 0.5
        circleLabel.layer.borderWidth = 0.5
        circleLabel.layer.backgroundColor = UIColor.clear.cgColor
        circleLabel.layer.borderColor = UIColor.black.cgColor
        circleLabel.baselineAdjustment = .alignCenters
        
        mnemonicLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 14)
    }

    class func getCellIdentifier() -> String {
        return "MnemonicCollectionViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 30
    }
}
