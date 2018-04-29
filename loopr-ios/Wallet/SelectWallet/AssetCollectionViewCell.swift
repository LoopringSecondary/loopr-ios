//
//  AssetCollectionViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/29.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    
    var asset: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconView.backgroundColor = .clear
    }
    
    func update() {
        if let asset = self.asset {
            if let image = UIImage(named: asset) {
                iconImageView.image = image
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = asset
                iconView.symbolLabel.text = asset
                iconImageView.isHidden = true
            }
        }
    }
    
    class func getCellIdentifier() -> String {
        return "AssetCollectionViewCell"
    }

}
