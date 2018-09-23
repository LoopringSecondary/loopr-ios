//
//  SetGasViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/24.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import StepSlider

class SetGasViewController: UIViewController, StepSliderDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gasValueLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var recommendButtonWidth: NSLayoutConstraint!
    
    var minGasValue: Double = 1
    var maxGasValue: Double = 0
    private let recGasPriceInGwei: Double = GasDataManager.shared.getGasRecommendedPrice()
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()
    var stepSlider: StepSlider = StepSlider.getDefault()
    var dismissClosure: (() -> Void)?
    
    var isViewDidAppear: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        seperateLine.theme_backgroundColor = ColorPicker.cardHighLightColor
        
        titleLabel.theme_textColor = GlobalPicker.textColor
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        titleLabel.text = LocalizedString("Set Gas", comment: "")
        
        gasValueLabel.theme_textColor = GlobalPicker.textColor
        gasValueLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        
        gasTipLabel.setSubTitleDigitFont()

        recommendButton.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        recommendButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 13)
        recommendButton.title = LocalizedString("Recommend Price", comment: "")
        let language = Bundle.main.preferredLocalizations.first
        if language == "zh-Hans" {
            recommendButtonWidth.constant = 80
        } else {
            recommendButtonWidth.constant = 120
        }

        closeButton.theme_setImage(GlobalPicker.close, forState: .normal)
        closeButton.theme_setImage(GlobalPicker.closeHighlight, forState: .highlighted)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        stepSlider.frame = CGRect(x: 15, y: gasTipLabel.bottomY + 24, width: UIScreen.main.bounds.width - 15 * 2, height: 44)
        stepSlider.delegate = self
        stepSlider.maxCount = 2
        stepSlider.trackCircleRadius = 0
        stepSlider.setIndex(0, animated: false)
        stepSlider.labels = [LocalizedString("Slow", comment: ""), LocalizedString("Fast", comment: "")]
        containerView.addSubview(stepSlider)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        headerView.addGestureRecognizer(tap)
        
        self.maxGasValue = Double(recGasPriceInGwei * 2) <= 20 ? 20 : Double(recGasPriceInGwei * 2)
        update(self.gasPriceInGwei)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isViewDidAppear {
            print(Float(gasPriceInGwei-1)/Float(maxGasValue))
            stepSlider.setPercentageValue(Float(gasPriceInGwei-1)/Float(maxGasValue-1))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewDidAppear = true
    }
    
    func update(_ gasPriceInGwei: Double) {
        let amountInEther = gasPriceInGwei / 1000000000
        let gasLimit = Double(GasDataManager.shared.getGasLimit(by: "token_transfer")!)
        let totalGasInEther = amountInEther * gasLimit
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let transactionFeeInFiat = totalGasInEther * etherPrice
            gasValueLabel.text = "\(totalGasInEther.withCommas(6)) ETH ≈ \(transactionFeeInFiat.currency)"
            gasTipLabel.text = "Gas Limit (\(gasLimit)) * Gas Price (\(gasPriceInGwei) Gwei)"
        }
        
        print(Float(gasPriceInGwei-1)/Float(maxGasValue))
        stepSlider.setPercentageValue(Float(gasPriceInGwei-1)/Float(maxGasValue-1))
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

    @IBAction func pressedRecommandButton(_ sender: UIButton) {
        GasDataManager.shared.setGasPrice(in: self.recGasPriceInGwei)
        self.update(self.recGasPriceInGwei)
    }
    
    @IBAction func pressedCloseButton(_ sender: UIButton) {
        close()
    }
    
    func stepSliderValueChanged(_ value: Double) {
        let distance = self.maxGasValue - self.minGasValue
        let roundedStepValue = round(distance * value + self.minGasValue)
        self.gasPriceInGwei = roundedStepValue
        GasDataManager.shared.setGasPrice(in: gasPriceInGwei)
        update(self.gasPriceInGwei)
    }
}
