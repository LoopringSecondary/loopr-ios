//
//  OrderHistoryTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {

    var order: Order?
    let asset = AssetDataManager.shared
    let market = MarketDataManager.shared
    let price = PriceQuoteDataManager.shared
    
    @IBOutlet weak var filledPieChart: CircleChart!
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update() {
        guard let order = self.order else { return }
        initPriceLabel(order: order)
        initOrderFilled(order: order)
        initOrderTypeLabel(order: order)
        tradingPairLabel.text = order.tradingPairDescription
        volumeLabel.text = "Vol " + order.dealtAmountS.description
        cancelButton.layer.cornerRadius = 15
        cancelButton.layer.borderColor = UIColor.gray.cgColor
        cancelButton.borderWidth = 0.5
    }
    
    func initPriceLabel(order: Order) {
        let trade = order.originalOrder.market
        let balance = market.getBalance(of: trade)
        amountLabel.text = balance.description
        let pair = trade.components(separatedBy: "-")
        if let display = price.getPriceBySymbol(of: pair[0]) {
            // TODO: according to setting currency
            displayLabel.text = "$ " + display.description
        } else {
            displayLabel.text = "$ --"
        }
        displayLabel.textColor = .gray
    }
    
    func initOrderTypeLabel(order: Order) {
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
    
    func initOrderFilled(order: Order) {
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
    
    class func getCellIdentifier() -> String {
        return "OrderHistoryTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 80
    }
}
