//
//  SettingMarginSplitViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import StepSlider

class SettingMarginSplitViewController: UIViewController, StepSliderDelegate {

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
        view.addSubview(currentValueLabel)
        
        stepSlider = StepSlider.init(frame: CGRect(x: padding, y: currentValueLabel.frame.maxY + padding + 10, width: screenWidth-padding*2, height: 20))
        stepSlider.delegate = self
        stepSlider.maxCount = 2
        // stepSlider.setIndex(0, animated: false)
        stepSlider.labels = ["0%", "100%"]
        currentValue = SettingDataManager.shared.getMarginSplit()

        let roundedStepValue = Int(round(currentValue*100))
        currentValueLabel.text = LocalizedString("Margin Split", comment: "") + ": \(roundedStepValue)" + NumberFormatter().percentSymbol

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
            stepSlider.setPercentageValue(Float(round(currentValue*100))/100.0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewDidAppear = true
        stepSlider.setPercentageValue(Float(round(currentValue*100))/100.0)
    }
    
    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: StepSlider.self) {
            return false
        }
        return true
    }
    
    @objc func pressedSaveButton(_ sender: Any) {
        let roundedStepValue = Int(round(currentValue*100))
        SettingDataManager.shared.setMarginSplit(Double(roundedStepValue)/100.0)
        self.navigationController?.popViewController(animated: true)
    }

    func stepSliderValueChanged(_ value: Double) {
        currentValue = value
        let roundedStepValue = Int(round(currentValue*100))
        currentValueLabel.text = LocalizedString("Margin Split", comment: "") + ": \(roundedStepValue)" + NumberFormatter().percentSymbol
    }

}
