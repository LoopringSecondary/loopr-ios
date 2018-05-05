//
//  SettingMarginSplitViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingMarginSplitViewController: UIViewController {

    var slider = UISlider()
    var currentValueLabel = UILabel()
    var minLabel = UILabel()
    var maxLabel = UILabel()
    
    var saveButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("LRC Fee Ratio", comment: "")
        setBackButton()
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        currentValueLabel.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 30)
        currentValueLabel.font = FontConfigManager.shared.getLabelFont()
        currentValueLabel.text = NSLocalizedString("Margin Split", comment: "") + ": \(SettingDataManager.shared.getMarginSplitDescription())"
        view.addSubview(currentValueLabel)
        
        slider.frame = CGRect(x: padding, y: currentValueLabel.frame.maxY + padding + 10, width: screenWidth-padding*2, height: 20)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = Float(SettingDataManager.shared.getMarginSplit() * 100.0)
        
        slider.isContinuous = true
        slider.tintColor = UIColor.black
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        minLabel.frame = CGRect(x: padding, y: slider.frame.maxY + 10, width: 100, height: 30)
        minLabel.font = FontConfigManager.shared.getLabelFont()
        minLabel.text = "0%"
        view.addSubview(minLabel)
        
        maxLabel.textAlignment = .right
        maxLabel.frame = CGRect(x: screenWidth-padding-100, y: minLabel.frame.minY, width: 100, height: 30)
        maxLabel.font = FontConfigManager.shared.getLabelFont()
        maxLabel.text = "100%"
        view.addSubview(maxLabel)
        
        saveButton.setupRoundBlack()
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveButton.frame = CGRect(x: padding, y: minLabel.frame.maxY + padding*2 + 10, width: screenWidth - padding*2, height: 47)
        saveButton.addTarget(self, action: #selector(pressedSaveButton), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        let step: Float = 1
        let roundedStepValue = Int(round(sender.value / step))
        let perMillSymbol = NumberFormatter().perMillSymbol!
        currentValueLabel.text = NSLocalizedString("Margin Split", comment: "") + ": \(roundedStepValue)\(perMillSymbol)"
    }
    
    @objc func pressedSaveButton(_ sender: Any) {
        let step: Float = 1
        let newValue = Double(round(slider.value / step)) / 100.0
        SettingDataManager.shared.setMarginSplit(newValue)
        self.navigationController?.popViewController(animated: true)
    }

}
