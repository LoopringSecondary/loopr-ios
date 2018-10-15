//
//  SetLRCRatioFeeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import StepSlider

class SetLRCRatioFeeViewController: UIViewController, StepSliderDelegate {

    var stepSlider = StepSlider.getDefault()
    var currentValue: Double = 0
    var currentValueLabel = UILabel(frame: .zero)
    var tipLabel = UILabel(frame: .zero)
    
    var isViewDidAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.navigationItem.title = LocalizedString("LRC Fee Ratio", comment: "")
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        let originY: CGFloat = 18
        let padding: CGFloat = screenHeight - 300
        
        currentValueLabel.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 22)
        currentValueLabel.setTitleDigitFont()
        currentValueLabel.text = LocalizedString("LRC Fee Ratio", comment: "") + ": \(SettingDataManager.shared.getLrcFeeRatioDescription())"
        view.addSubview(currentValueLabel)
        
        currentValue = SettingDataManager.shared.getLrcFeeRatio()
        
        stepSlider.frame = CGRect(x: 24, y: currentValueLabel.frame.maxY + 30, width: screenWidth-24*2, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 2
        stepSlider.trackCircleRadius = 0
        stepSlider.labels = [LocalizedString("Slow", comment: ""), LocalizedString("Fast", comment: "")]
        stepSlider.setPercentageValue(Float((currentValue-0.001)/0.049))
        
        tipLabel.frame = CGRect(x: 24, y: stepSlider.frame.maxY + 50, width: screenWidth-24*2, height: 20)
        tipLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        tipLabel.theme_textColor = ["#00000099", "#ffffff66"]
        
        let title = LocalizedString("Lrc_Fee_Tip", comment: "")
        let amount = GasDataManager.shared.getGasAmount(by: "eth_transfer", in: "LRC")
        tipLabel.text = "\(title) \(amount.withCommas()) LRC"
        view.addSubview(tipLabel)
        
        let saveButon = UIBarButtonItem(title: LocalizedString("Save", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pressedSaveButton))
        saveButon.setTitleTextAttributes([NSAttributedStringKey.font: FontConfigManager.shared.getCharactorFont(size: 14)], for: .normal)
        self.navigationItem.rightBarButtonItem = saveButon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isViewDidAppear {
            view.addSubview(stepSlider)
            print(Float(round(currentValue*1000))/1000.0)
            stepSlider.setPercentageValue(Float((currentValue-0.001)/0.049))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewDidAppear = true
        print(Float(round(currentValue*100))/100.0)
        stepSlider.setPercentageValue(Float((currentValue-0.001)/0.049))
    }
    
    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: StepSlider.self) {
            return false
        }
        return true
    }
    
    @objc func pressedSaveButton(_ sender: Any) {
        // Format the Double value
        let roundedStepValue = Int(round(currentValue*1000))
        SettingDataManager.shared.setLrcFeeRatio(Double(roundedStepValue)/1000.0)
        self.navigationController?.popViewController(animated: true)
    }
    
    func stepSliderValueChanged(_ value: Double) {
        currentValue = (value*49 + 1)/1000
        let roundedStepValue = round(currentValue*1000)/10
        let percentSymbol = NumberFormatter().percentSymbol!
        currentValueLabel.text = LocalizedString("LRC Fee Ratio", comment: "") + ": \(roundedStepValue)\(percentSymbol)"
    }

}
