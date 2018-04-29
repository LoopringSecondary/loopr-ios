//
//  SelectWalletTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import FoldingCell

class SelectWalletTableViewCell: FoldingCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var frontView: RotatedView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontTop: NSLayoutConstraint!
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var toatalBalanceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var enterButton: UIButton!
    
    var wallet: AppWallet?
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {

        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }

    override func awakeFromNib() {
        foregroundView = frontView
        containerView = backView
        foregroundViewTop = frontTop
        containerViewTop = backTop
        super.awakeFromNib()
        // Initialization code
        theme_backgroundColor = GlobalPicker.backgroundColor
        frontView.layer.cornerRadius = 20
        backView.layer.cornerRadius = 20
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "AssetCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "AssetCollectionViewCell")
        setup()
    }
    
    func setup() {
        nameLabel.theme_textColor = GlobalPicker.textColor
        nameLabel.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 17)
        addressLabel.theme_textColor = GlobalPicker.textColor
        addressLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 11)
        notifyLabel.isHidden = true
        toatalBalanceLabel.theme_textColor = GlobalPicker.textColor
        toatalBalanceLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 24)
        
        enterButton.layer.borderWidth = 1
        enterButton.layer.cornerRadius = 18
        enterButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)
        enterButton.titleColor = Themes.isNight() ? .white : .black
        enterButton.layer.borderColor = UIColor.init(rgba: "#A5A5A5").cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let wallet = wallet {
            nameLabel.text = wallet.name
            addressLabel.text = wallet.address
            toatalBalanceLabel.text = wallet.totalCurrency.currency
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let wallet = self.wallet {
            return wallet.assetSequenceInHideSmallAssets.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.getCellIdentifier(), for: indexPath) as? AssetCollectionViewCell
        if let wallet = self.wallet {
            cell?.asset = wallet.getAssetSequenceInHideSmallAssets()[indexPath.row]
        }
        cell?.update()
        return cell!
    }

    class func getCellIdentifier() -> String {
        return "SelectWalletTableViewCell"
    }
}
