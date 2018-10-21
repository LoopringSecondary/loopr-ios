//
//  TTLViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/30.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class TimeToLiveViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    // Data source
    var dateDictionary: [Int: Int] = [0: 23, 1: 30, 2: 12]
    var pickerTitle: [String] = [LocalizedString("Hour", comment: ""), LocalizedString("Day", comment: ""), LocalizedString("Month", comment: "")]
    var pickerType: [Calendar.Component] = [.hour, .day, .month]
    
    var orderIntervalTime = SettingDataManager.shared.getOrderIntervalTime()

    let width: CGFloat = UIScreen.main.bounds.width / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom

        seperateLine.theme_backgroundColor = ColorPicker.cardHighLightColor
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(orderIntervalTime.intervalValue-1, inComponent: 0, animated: true)
        pickerView.selectRow(pickerType.index(of: orderIntervalTime.intervalUnit) ?? 0, inComponent: 1, animated: true)
        
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Time to Live", comment: "")
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
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
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return pickerTitle.count
        } else {
            switch orderIntervalTime.intervalUnit {
            case .hour:
                return 24
            case .day:
                return 30
            case .month:
                return 12
            default:
                return 24
            }
        }
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
        if component == 0 {
            label.text = "\(row + 1)"
        } else {
            label.text = pickerTitle[row]
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            orderIntervalTime.intervalUnit = pickerType[row]
        } else {
            orderIntervalTime.intervalValue = row + 1
        }
        pickerView.reloadComponent(0)
    }

}
