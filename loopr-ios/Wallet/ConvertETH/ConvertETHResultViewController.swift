//
//  SendResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/29.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class ConvertETHResultViewController: UIViewController {
    
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var toTipLabel: UILabel!
    @IBOutlet weak var toInfoLabel: UILabel!
    @IBOutlet weak var timeTipLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var doneButton: GradientButton!
    
    @IBOutlet weak var seperatorA: UIView!
    @IBOutlet weak var seperatorB: UIView!
    @IBOutlet weak var seperatorC: UIView!
    @IBOutlet weak var seperatorD: UIView!
    
    var convertAsset: Asset?
    var otherAsset: Asset?
    var convertAmount: String!
    var receiveAddress: String!
    var errorMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        let seperators = [seperatorA, seperatorB, seperatorC, seperatorD]
        seperators.forEach { $0?.theme_backgroundColor = ColorPicker.cardBackgroundColor }
        
        doneButton.title = LocalizedString("Done", comment: "")
        doneButton.setPrimaryColor()
        if let asset = self.convertAsset {
            update(asset: asset)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
            toTipLabel.text = LocalizedString("Receive Token", comment: "")
            toInfoLabel.text = "+\(convertAmount!) \(otherAsset!.symbol)"
        }
        balanceLabel.font = FontConfigManager.shared.getDigitalFont(size: 16)
        balanceLabel.text = "-\(convertAmount!) \(asset.symbol)"
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
        // Pop to TradeSelectionViewController
        for controller in self.navigationController!.viewControllers as Array {
            // Jumps back to the second tab
            if controller.isKind(of: TradeSelectionViewController.self) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
            
            // Jumps back to asset detail view controller
            if controller.isKind(of: AssetSwipeViewController.self) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}
