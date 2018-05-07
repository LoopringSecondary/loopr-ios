//
//  OrderTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    var order: Order?
    let asset = CurrentAppWalletDataManager.shared
    let market = MarketDataManager.shared
    
    @IBOutlet weak var filledPieChart: CircleChart!
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var pressedCancelButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update() {
        guard let order = self.order else { return }
        
        setupTradingPairlabel(order: order)
        setupVolumeLabel(order: order)
        setupAmountLabel(order: order)
        setupPriceLabel(order: order)
        setupOrderTypeLabel(order: order)
        setupOrderFilled(order: order)
        
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.titleColor = UIColor.black
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.cornerRadius = 15
        cancelButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 12.0)
    }
    
    func setupTradingPairlabel(order: Order) {
        tradingPairLabel.theme_textColor = GlobalPicker.textColor
        tradingPairLabel.text = order.tradingPairDescription
        tradingPairLabel.font = FontConfigManager.shared.getLabelFont()
    }
    
    func setupVolumeLabel(order: Order) {
        volumeLabel.text = "Vol " + order.dealtAmountS.description
        volumeLabel.theme_textColor = ["#a0a0a0", "#fff"]
        volumeLabel.font = FontConfigManager.shared.getLabelFont()
    }
    
    func setupAmountLabel(order: Order) {
        if order.originalOrder.side.lowercased() == "sell" {
            amountLabel.text = order.originalOrder.amountSell.description
        } else if order.originalOrder.side.lowercased() == "buy" {
            amountLabel.text = order.originalOrder.amountBuy.description
        }
        amountLabel.theme_textColor = GlobalPicker.textColor
        amountLabel.font = FontConfigManager.shared.getLabelFont()
    }
    
    func setupPriceLabel(order: Order) {
        let pair = order.originalOrder.market.components(separatedBy: "-")
        if let price = PriceDataManager.shared.getPriceBySymbol(of: pair[0]) {
            displayLabel.text = price.currency
        } else {
            displayLabel.text = "--"
        }
        displayLabel.theme_textColor = ["#a0a0a0", "#fff"]
        displayLabel.font = FontConfigManager.shared.getLabelFont()
    }
    
    func setupOrderTypeLabel(order: Order) {
        orderTypeLabel.text = order.originalOrder.side
        orderTypeLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 10)
        orderTypeLabel.borderWidth = 0.5
        if order.originalOrder.side == "buy" {
            orderTypeLabel.backgroundColor = UIColor.black
            orderTypeLabel.textColor = UIColor.white
        } else if order.originalOrder.side == "sell" {
            orderTypeLabel.backgroundColor = UIColor.white
            orderTypeLabel.textColor = UIColor.black
            orderTypeLabel.borderColor = UIColor.gray
        }
        orderTypeLabel.layer.cornerRadius = 2.0
        orderTypeLabel.layer.masksToBounds = true
    }
    
    func setupOrderFilled(order: Order) {
        var percent: Double = 0.0
        if order.originalOrder.side.lowercased() == "sell" {
            percent = order.dealtAmountS / order.originalOrder.amountSell
        } else if order.originalOrder.side.lowercased() == "buy" {
            percent = order.dealtAmountB / order.originalOrder.amountBuy
        }
        filledPieChart.theme_backgroundColor = GlobalPicker.backgroundColor
        filledPieChart.strokeColor = Themes.isNight() ? UIColor.white.cgColor : UIColor.black.cgColor
        filledPieChart.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        filledPieChart.textFont = UIFont(name: FontConfigManager.shared.getLight(), size: 10.0)!
        filledPieChart.desiredLineWidth = 1
        filledPieChart.percentage = CGFloat(percent)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        if let btnAction = self.pressedCancelButtonClosure {
            btnAction()
        }
    }
    
    class func getCellIdentifier() -> String {
        return "OrderTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 80
    }
}
