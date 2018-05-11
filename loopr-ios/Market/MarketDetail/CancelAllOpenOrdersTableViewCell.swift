//
//  CancelAllOpenOrdersTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class CancelAllOpenOrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var hideOtherPairsSwitch: UISwitch!    
    @IBOutlet weak var hideOtherPairsLabel: UILabel!
    @IBOutlet weak var cancelAllButton: UIButton!
    @IBOutlet weak var seperateLine: UIView!

    var pressedCancelAllButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        hideOtherPairsSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        hideOtherPairsSwitch.setOn(SettingDataManager.shared.getHideOtherPairs(), animated: false)
        hideOtherPairsLabel.textColor = UIColor.black
        hideOtherPairsLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17.0)

        cancelAllButton.title = NSLocalizedString("Cancel All", comment: "")
        cancelAllButton.backgroundColor = UIColor.clear
        cancelAllButton.titleColor = UIColor.black
        cancelAllButton.layer.borderWidth = 0.5
        cancelAllButton.layer.borderColor = UIColor.black.cgColor
        cancelAllButton.layer.cornerRadius = 15
        cancelAllButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 12.0)

        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }
    
    @IBAction func toggleHidePairSwitch(_ sender: UISwitch) {
        SettingDataManager.shared.setHideOtherPair(hideOtherPairsSwitch.isOn)
    }
    
    @IBAction func pressedCancelAllOpenOrdersButton(_ sender: Any) {
        print("pressedCancelAllOpenOrdersButton")
        if let btnAction = self.pressedCancelAllButtonClosure {
            btnAction()
        }
    }

    class func getCellIdentifier() -> String {
        return "CancelAllOpenOrdersTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 55
    }
}
