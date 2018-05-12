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
    var toggleHidePairSwitchClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hideOtherPairsSwitch.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        hideOtherPairsSwitch.setOn(SettingDataManager.shared.getHideOtherPairs(), animated: false)
        hideOtherPairsLabel.textColor = UIColor.black
        hideOtherPairsLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17.0*UIStyleConfig.scale)
        setupCancelAllButton()
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }
    
    func setupCancelAllButton() {
        if OrderDataManager.shared.getDateOrders(orderStatuses: [.opened]).count == 0 || UserDefaults.standard.bool(forKey: UserDefaultsKeys.cancelledAll.rawValue) {
            cancelAllButton.isEnabled = false
            cancelAllButton.backgroundColor = UIColor(rgba: "#e0e0e0")
            cancelAllButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            cancelAllButton.isEnabled = true
            cancelAllButton.backgroundColor = UIColor.clear
            cancelAllButton.layer.borderWidth = 0.5
            cancelAllButton.layer.borderColor = UIColor.black.cgColor
        }
        cancelAllButton.title = NSLocalizedString("Cancel All", comment: "")
        cancelAllButton.titleColor = UIColor.black
        cancelAllButton.layer.cornerRadius = 15
        cancelAllButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toggleHidePairSwitch(_ sender: UISwitch) {
        SettingDataManager.shared.setHideOtherPair(hideOtherPairsSwitch.isOn)
        if let action = self.toggleHidePairSwitchClosure {
            action()
        }
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
