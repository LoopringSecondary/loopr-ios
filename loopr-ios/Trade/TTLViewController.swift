//
//  TTLViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/30.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class TTLViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    // Data source
    var dateDictionary: [Int: Int]?
    var picker2: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateDictionary = [0: 23, 1: 30, 2: 12]
        picker2 = ["Hour", "Day", "Month"]
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return picker2!.count
        } else {
            return 30
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row + 1)"
        } else {
            return picker2?[row]
        }
    }

}
