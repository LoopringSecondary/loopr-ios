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

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gasValueLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recommandButton: UIButton!
    
    var minGasValue: Double = 1
    var maxGasValue: Double = 0
    private let recGasPriceInGwei: Double = GasDataManager.shared.getGasRecommendedPrice()
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()
    var stepSlider: StepSlider = StepSlider()
    var dismissClosure: (() -> Void)?
    
    var isViewDidAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = .custom
        // Do any additional setup after loading the view.
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Set Gas", comment: "")
        gasValueLabel.setTitleDigitFont()
        gasTipLabel.setSubTitleDigitFont()
        recommandButton.setupSecondary(height: 32)
        recommandButton.titleLabel?.theme_textColor = GlobalPicker.textColor
        recommandButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 12)
        recommandButton.title = LocalizedString("Recommand Price", comment: "")
        
        closeButton.theme_setImage(GlobalPicker.close, forState: .normal)
        closeButton.theme_setImage(GlobalPicker.closeHighlight, forState: .highlighted)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        stepSlider = StepSlider.init(frame: CGRect(x: 16, y: gasTipLabel.bottomY + 24, width: containerView.width - 16 * 2, height: 44))
        stepSlider.delegate = self
        stepSlider.maxCount = 2
        stepSlider.setIndex(0, animated: false)
        stepSlider.labelFont = FontConfigManager.shared.getRegularFont(size: 12)
        stepSlider.labelColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.labels = [LocalizedString("Slow", comment: ""), LocalizedString("Fast", comment: "")]
        stepSlider.trackHeight = 2
        stepSlider.trackCircleRadius = 3
        stepSlider.trackColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.tintColor = UIColor.themeGreen
        stepSlider.sliderCircleRadius = 10
        stepSlider.sliderCircleColor = UIColor.themeGreen
        stepSlider.labelOffset = 10
        stepSlider.isDotsInteractionEnabled = true
        stepSlider.adjustLabel = true

        containerView.addSubview(stepSlider)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        if containerView.frame.contains(location) {
            return false
        }
        return true
    }
    
    @IBAction func pressedRecommandButton(_ sender: UIButton) {
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
