//
//  SetGasViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/24.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SetGasViewController: UIViewController, DefaultSliderDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gasValueLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recommandButton: UIButton!
    
    var dismissClosure: (() -> Void)?
    var recGasPriceInGwei: Double = 0
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = .custom
        // Do any additional setup after loading the view.
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Set Gas", comment: "")
        gasValueLabel.setTitleDigitFont()
        gasTipLabel.setSubTitleDigitFont()
        recommandButton.setupSecondary(height: 32)
        recommandButton.titleLabel?.theme_textColor = ["#000000cc", "#ffffffcc"]
        recommandButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 12)
        recommandButton.title = LocalizedString("Recommand Price", comment: "")
        
        closeButton.theme_setImage(GlobalPicker.close, forState: .normal)
        closeButton.theme_setImage(GlobalPicker.closeHighlight, forState: .highlighted)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        updateLabels(self.recGasPriceInGwei)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabels(_ gasPriceInGwei: Double) {
        let amountInEther = gasPriceInGwei / 1000000000
        let gasLimit = Double(GasDataManager.shared.getGasLimit(by: "token_transfer")!)
        let totalGasInEther = amountInEther * gasLimit
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let transactionFeeInFiat = totalGasInEther * etherPrice
            gasValueLabel.text = "\(totalGasInEther) ETH ≈ \(transactionFeeInFiat.currency)"
            gasTipLabel.text = "Gas Limit(\(gasLimit)) * Gas Price(\(gasPriceInGwei) Gwei)"
        }
    }
    
    @IBAction func pressedRecommandButton(_ sender: UIButton) {
        self.updateLabels(self.recGasPriceInGwei)
    }
    
    @IBAction func pressedCloseButton(_ sender: UIButton) {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
}
