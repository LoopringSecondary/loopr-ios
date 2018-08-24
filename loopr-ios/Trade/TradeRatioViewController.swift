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
    @IBOutlet weak var pickerView: UIPickerView!
    
    var sellRatio: Double = 1
    var titleArray = [Int]()
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    let width: CGFloat = UIScreen.main.bounds.width / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        pickerView.delegate = self
        pickerView.dataSource = self
        titleArray = Array(stride(from: 100, through: 5, by: -5))
        
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Minimal Fill", comment: "")
        
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
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
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
        label.text = "\(titleArray[row])" + NumberFormatter().percentSymbol
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.sellRatio = Double(titleArray[row]) / Double(100)
    }

}
