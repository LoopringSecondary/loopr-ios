//
//  SetGasViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/7/24.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SetGasViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gasValueLabel: UILabel!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var arrowDownButton: UIButton!
    @IBOutlet weak var recommandButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Set Gas", comment: "")
        gasValueLabel.setTitleDigitFont()
        gasTipLabel.setSubTitleDigitFont()
        recommandButton.titleLabel?.setTitleCharFont()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
