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

class SendConfirmViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var toTipLabel: UILabel!
    @IBOutlet weak var toInfoLabel: UILabel!
    @IBOutlet weak var fromTipLabel: UILabel!
    @IBOutlet weak var fromInfoLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var gasInfoLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var sendAsset: Asset!
    var sendAmount: String!
    var receiveAddress: String!
    var gasAmountText: String!
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        view.backgroundColor = .clear
        
        titleLabel.theme_textColor = GlobalPicker.textColor
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        titleLabel.text = LocalizedString("Send Confirmation", comment: "")
        
        amountLabel.font = FontConfigManager.shared.getDigitalFont()
        amountLabel.textColor = .success
        amountLabel.text = "\(self.sendAmount!) \(self.sendAsset.symbol)"
        
        toTipLabel.setTitleCharFont()
        toTipLabel.text = LocalizedString("Receiver", comment: "")
        toInfoLabel.font = FontConfigManager.shared.getLightFont(size: 12)
        toInfoLabel.theme_textColor = GlobalPicker.textLightColor
        toInfoLabel.text = self.receiveAddress ?? ""
        toInfoLabel.lineBreakMode = .byTruncatingMiddle
        
        fromTipLabel.setTitleCharFont()
        fromTipLabel.text = LocalizedString("Sender", comment: "")
        fromInfoLabel.font = FontConfigManager.shared.getLightFont(size: 12)
        fromInfoLabel.theme_textColor = GlobalPicker.textLightColor
        fromInfoLabel.text = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address
        fromInfoLabel.lineBreakMode = .byTruncatingMiddle
        
        gasTipLabel.setTitleCharFont()
        gasTipLabel.text = LocalizedString("Transaction Fee", comment: "")
        gasInfoLabel.font = FontConfigManager.shared.getLightFont(size: 12)
        gasInfoLabel.theme_textColor = GlobalPicker.textLightColor
        gasInfoLabel.text = gasAmountText
        
        sendButton.setupPrimary(height: 44)
        sendButton.title = LocalizedString("Send", comment: "")
        
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
    
    @IBAction func pressedSendButton(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Processing the transaction ...")
        if let toAddress = self.receiveAddress,
            let token = TokenDataManager.shared.getTokenBySymbol(self.sendAsset.symbol) {
            var error: NSError?
            let toAddress = GethNewAddressFromHex(toAddress, &error)!
            if token.symbol.uppercased() == "ETH" {
                let amount = Double(self.sendAmount)!
                let gethAmount = GethBigInt.generate(valueInEther: amount, symbol: token.symbol)!
                SendCurrentAppWalletDataManager.shared._transferETH(amount: gethAmount, toAddress: toAddress, completion: completion)
            } else {
                let amount = Double(self.sendAmount)!
                let gethAmount = GethBigInt.generate(valueInEther: amount, symbol: token.symbol)!
                let contractAddress = GethNewAddressFromHex(token.protocol_value, &error)!
                SendCurrentAppWalletDataManager.shared._transferToken(contractAddress: contractAddress, toAddress: toAddress, tokenAmount: gethAmount, completion: completion)
            }
        }
    }
    
}

extension SendConfirmViewController {
    
    func completion(_ txHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            let vc = SendResultViewController()
            vc.asset = self.sendAsset
            vc.sendAmount = self.sendAmount
            vc.receiveAddress = self.receiveAddress
            vc.navigationItem.title = "转账"
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
