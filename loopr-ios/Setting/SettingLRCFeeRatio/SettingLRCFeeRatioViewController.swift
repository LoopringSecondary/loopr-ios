//
//  SettingLRCFeeRatioViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import StepSlider

// It's designed not to merge SettingLRCFeeRatioViewController and SettingMarginSplitViewController
class SettingLRCFeeRatioViewController: UIViewController, StepSliderDelegate {

    var stepSlider = StepSlider.getDefault()
    var currentValue: Double = 0
    var currentValueLabel = UILabel()

    var isViewDidAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = LocalizedString("LRC Fee Ratio", comment: "")
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        currentValueLabel.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 30)
        currentValueLabel.setTitleDigitFont()
        currentValueLabel.text = LocalizedString("LRC Fee Ratio", comment: "") + ": \(SettingDataManager.shared.getLrcFeeRatioDescription())"
        view.addSubview(currentValueLabel)
        
        currentValue = SettingDataManager.shared.getLrcFeeRatio()

        stepSlider.frame = CGRect(x: padding, y: currentValueLabel.frame.maxY + padding + 10, width: screenWidth-padding*2, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 2
        // stepSlider.setIndex(0, animated: false)
        stepSlider.labels = [LocalizedString("slow", comment: ""), LocalizedString("fast", comment: "")]
        stepSlider.setPercentageValue(Float((currentValue-0.001)/0.049))

        let saveButon = UIBarButtonItem(title: LocalizedString("Save", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pressedSaveButton))
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
        let roundedStepValue = Int(round(currentValue*1000))
        SettingDataManager.shared.setLrcFeeRatio(Double(roundedStepValue)/1000.0)
        self.navigationController?.popViewController(animated: true)
    }

    func stepSliderValueChanged(_ value: Double) {
        currentValue = (value*49 + 1)/1000
        let roundedStepValue = Int(round(currentValue*1000))
        let perMillSymbol = NumberFormatter().perMillSymbol!
        currentValueLabel.text = LocalizedString("LRC Fee Ratio", comment: "") + ": \(roundedStepValue)\(perMillSymbol)"
    }

}
