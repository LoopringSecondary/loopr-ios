//
//  TradeRatioViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class TradeRatioViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Get the init value from TradeDataManager.
    var sellCount: Int = TradeDataManager.shared.sellCount
    var titleArray = [Int]()
    var digitArray = [Int]()
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    let width: CGFloat = UIScreen.main.bounds.width / 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        seperateLine.theme_backgroundColor = ColorPicker.cardHighLightColor

        pickerView.delegate = self
        pickerView.dataSource = self
        titleArray = Array(0...9)
        digitArray = [Int](repeating: 0, count: 4)
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Minimal Count", comment: "")
        
        digitArray[3] = sellCount%10
        pickerView.selectRow(digitArray[3], inComponent: 3, animated: true)
        
        digitArray[2] = (sellCount/10)%10
        pickerView.selectRow(digitArray[2], inComponent: 2, animated: true)
        
        digitArray[1] = (sellCount/100)%10
        pickerView.selectRow(digitArray[1], inComponent: 1, animated: true)

        digitArray[0] = (sellCount/1000)%10
        pickerView.selectRow(digitArray[0], inComponent: 0, animated: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func pressedCloseButton(_ sender: UIButton) {
        close()
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        label.textAlignment = .center
        label.setTitleDigitFont()
        label.text = "\(titleArray[row])"
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        digitArray[component] = row
        self.sellCount = digitArray[0] * 1000 + digitArray[1] * 100 + digitArray[2] * 10 + digitArray[3]
        if self.sellCount == 0 {
            self.sellCount = 1
        }
    }
}
