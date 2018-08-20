//
//  SendResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/29.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SendResultViewController: UIViewController {
    
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var toTipLabel: UILabel!
    @IBOutlet weak var toInfoLabel: UILabel!
    @IBOutlet weak var timeTipLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var asset: Asset?
    var sendAmount: String!
    var receiveAddress: String!
    var errorMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        doneButton.title = LocalizedString("Done", comment: "")
        doneButton.setupPrimary(height: 44)
        if let asset = self.asset {
            update(asset: asset)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(asset: Asset) {
        if let errorMessage = self.errorMessage {
            statusIcon.image = UIImage.init(named: "Result-header-fail")
            balanceLabel.textColor = UIColor.fail
            statusInfoLabel.textColor = UIColor.fail
            statusInfoLabel.text = LocalizedString("Failed", comment: "")
            toTipLabel.text = LocalizedString("Reason", comment: "")
            toInfoLabel.text = errorMessage
        } else {
            statusIcon.image = #imageLiteral(resourceName: "Result-header-success")
            balanceLabel.textColor = UIColor.success
            statusInfoLabel.textColor = UIColor.pending
            statusInfoLabel.text = LocalizedString("Pending", comment: "")
            toTipLabel.text = LocalizedString("To", comment: "")
            toInfoLabel.text = receiveAddress
        }
        balanceLabel.font = FontConfigManager.shared.getDigitalFont(size: 16)
        balanceLabel.text = "-\(sendAmount!) \(asset.symbol)"
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 15)
        toTipLabel.setTitleCharFont()
        toInfoLabel.setTitleCharFont()
        timeTipLabel.setTitleCharFont()
        timeTipLabel.text = LocalizedString("Time", comment: "")
        timeInfoLabel.setTitleCharFont()
        let stamp = UInt(Date().timeIntervalSince1970)
        timeInfoLabel.text = DateUtil.convertToDate(stamp, format: "yyyy-MM-dd HH:mm")
    }

    @IBAction func pressedDoneButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
