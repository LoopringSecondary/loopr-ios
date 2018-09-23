//
//  SendConfirmViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/29.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import Geth
import SVProgressHUD

class ConvertETHConfirmViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var toTipLabel: UILabel!
    @IBOutlet weak var toInfoLabel: UILabel!
    @IBOutlet weak var fromTipLabel: UILabel!
    @IBOutlet weak var fromInfoLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var gasInfoLabel: UILabel!
    @IBOutlet weak var convertButton: UIButton!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var cellA: UIView!
    @IBOutlet weak var cellB: UIView!
    @IBOutlet weak var cellC: UIView!
    
    var convertAsset: Asset!
    var otherAsset: Asset!
    var convertAmount: String!
    var gasAmountText: String!
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        view.backgroundColor = .clear
        
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        let cells = [cellA, cellB, cellC]
        cells.forEach { $0?.theme_backgroundColor = ColorPicker.cardBackgroundColor }
        cellBackgroundView.theme_backgroundColor = ColorPicker.cardHighLightColor
        
        titleLabel.theme_textColor = GlobalPicker.textColor
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        titleLabel.text = LocalizedString("Convert Confirmation", comment: "")
        
        amountLabel.font = FontConfigManager.shared.getDigitalFont()
        amountLabel.textColor = .success
        amountLabel.text = "\(self.convertAmount!) \(self.convertAsset.symbol)  →  \(self.otherAsset.symbol)"
        
        toTipLabel.text = LocalizedString("Receive Token", comment: "")
        toTipLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        toTipLabel.theme_textColor = GlobalPicker.textLightColor
        
        toInfoLabel.text = self.otherAsset.symbol
        toInfoLabel.lineBreakMode = .byTruncatingMiddle
        toInfoLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        toInfoLabel.theme_textColor = GlobalPicker.textColor
        
        fromTipLabel.text = LocalizedString("Send Token", comment: "")
        fromTipLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        fromTipLabel.theme_textColor = GlobalPicker.textLightColor
        
        fromInfoLabel.text = self.convertAsset.symbol
        fromInfoLabel.lineBreakMode = .byTruncatingMiddle
        fromInfoLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        fromInfoLabel.theme_textColor = GlobalPicker.textColor
        
        gasTipLabel.text = LocalizedString("Tx Fee Limit", comment: "")
        gasTipLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        gasTipLabel.theme_textColor = GlobalPicker.textLightColor
        
        gasInfoLabel.text = gasAmountText
        gasInfoLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        gasInfoLabel.theme_textColor = GlobalPicker.textColor

        convertButton.setupPrimary(height: 44)
        convertButton.title = LocalizedString("Convert", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func close() {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        close()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        if containerView.frame.contains(location) {
            return false
        }
        return true
    }
    
    @IBAction func pressedConvertButton(_ sender: UIButton) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to convert", comment: "")) { (error) in
                guard error == nil else {
                    return
                }
                self.authorizeToConvert()
            }
        } else {
            self.authorizeToConvert()
        }
    }

}

extension ConvertETHConfirmViewController {
    
    private func authorizeToConvert() {
        if let amount =  Double(self.convertAmount), let gethAmount = GethBigInt.generate(valueInEther: amount, symbol: self.convertAsset.symbol) {
            if convertAsset?.symbol.uppercased() == "ETH" {
                SendCurrentAppWalletDataManager.shared._deposit(amount: gethAmount, completion: completion)
            } else if convertAsset?.symbol.uppercased() == "WETH" {
                SendCurrentAppWalletDataManager.shared._withDraw(amount: gethAmount, completion: completion)
            }
        }
    }
    
    func completion(_ txHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            let vc = ConvertETHResultViewController()
            vc.convertAsset = self.convertAsset
            vc.otherAsset = self.otherAsset
            vc.convertAmount = self.convertAmount
            vc.navigationItem.title = LocalizedString("Convert", comment: "")
            if let error = error as NSError?,
                let json = error.userInfo["message"] as? JSON,
                let message = json.string {
                vc.errorMessage = message
            }
            if let closure = self.dismissClosure {
                closure()
            }
            self.dismiss(animated: true, completion: nil)
            self.parentNavController?.pushViewController(vc, animated: true)
        }
    }
}
