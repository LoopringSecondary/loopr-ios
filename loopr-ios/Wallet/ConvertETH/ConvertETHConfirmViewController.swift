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
        
        toTipLabel.setTitleCharFont()
        toTipLabel.text = LocalizedString("Receive Token", comment: "")
        toInfoLabel.setTitleDigitFont()
        toInfoLabel.text = self.otherAsset.symbol
        toInfoLabel.lineBreakMode = .byTruncatingMiddle
        
        fromTipLabel.setTitleCharFont()
        fromTipLabel.text = LocalizedString("Send Token", comment: "")
        fromInfoLabel.setTitleDigitFont()
        fromInfoLabel.text = self.convertAsset.symbol
        fromInfoLabel.lineBreakMode = .byTruncatingMiddle
        
        gasTipLabel.setTitleCharFont()
        gasTipLabel.text = LocalizedString("Transaction Fee", comment: "")
        gasInfoLabel.setTitleDigitFont()
        gasInfoLabel.text = gasAmountText
        
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
        if let amount =  Double(self.convertAmount), let gethAmount = GethBigInt.generate(valueInEther: amount, symbol: self.convertAsset.symbol) {
            if convertAsset?.symbol.uppercased() == "ETH" {
                SendCurrentAppWalletDataManager.shared._deposit(amount: gethAmount, completion: completion)
            } else if convertAsset?.symbol.uppercased() == "WETH" {
                SendCurrentAppWalletDataManager.shared._withDraw(amount: gethAmount, completion: completion)
            }
        }
    }
}

extension ConvertETHConfirmViewController {
    
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
