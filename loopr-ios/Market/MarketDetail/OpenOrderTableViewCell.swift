//
//  OpenOrderTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OpenOrderTableViewCell: UITableViewCell {

    var order: Order?
    
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var filledPieChart: CircleChart!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        tradingPairLabel.theme_textColor = GlobalPicker.textColor
        amountLabel.theme_textColor = ["#a0a0a0", "#fff"]
        filledPieChart.theme_backgroundColor = GlobalPicker.backgroundColor
        
        tradingPairLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17.0)
        amountLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 14.0)
        
        filledPieChart.strokeColor = Themes.isNight() ? UIColor.white.cgColor : UIColor.black.cgColor
        filledPieChart.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        filledPieChart.textFont = UIFont(name: FontConfigManager.shared.getLight(), size: 10.0)!
        filledPieChart.desiredLineWidth = 1
        
        // TODO: Use data from Replay API
        let num = Int(arc4random_uniform(100))
        filledPieChart.percentage = CGFloat(num)/100

        cancelButton.backgroundColor = UIColor.clear
        cancelButton.titleColor = UIColor.black
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.cornerRadius = 15
        cancelButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        guard let order = order else {
            return
        }
        tradingPairLabel.text = order.tradingPairDescription
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        print("pressedCancelButton")
    }
    
    class func getCellIdentifier() -> String {
        return "OpenOrderTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
