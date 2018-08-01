//
//  OrderTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var order: Order?
    let asset = CurrentAppWalletDataManager.shared
    let market = MarketDataManager.shared
    var pressedCancelButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.theme_backgroundColor = GlobalPicker.backgroundColor
    }
    
    func update() {
        guard let order = self.order else { return }
        setupTradingPairlabel(order: order)
        setupVolumeLabel(order: order)
        setupPriceLabel(order: order)
        setupOrderTypeLabel(order: order)
        setupCancelButton(order: order)
    }
    
    func setupCancelButton(order: Order) {
        let (flag, text) = getOrderStatus(order: order)
        if flag {
            cancelButton.isEnabled = true
        } else {
            cancelButton.isEnabled = false
        }
        cancelButton.title = text
        cancelButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 12)
    }
    
    func getOrderStatus(order: Order) -> (Bool, String) {
        if order.orderStatus == .opened {
            let cancelledAll = UserDefaults.standard.bool(forKey: UserDefaultsKeys.cancelledAll.rawValue)
            if cancelledAll || isOrderCancelling(order: order) {
                return (false, LocalizedString("Cancelling", comment: ""))
            } else {
                return (true, LocalizedString("Cancel", comment: ""))
            }
        } else {
            return (false, order.orderStatus.description)
        }
    }
    
    func isOrderCancelling(order: Order) -> Bool {
        let cancellingOrders = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.cancellingOrders.rawValue) ?? []
        return cancellingOrders.contains(order.originalOrder.hash)
    }
    
    func setupTradingPairlabel(order: Order) {
        tradingPairLabel.text = order.tradingPairDescription
        tradingPairLabel.setTitleDigitFont()
        tradingPairLabel.setMarket()
    }
    
    func setupVolumeLabel(order: Order) {
        if order.originalOrder.side.lowercased() == "sell" {
            volumeLabel.text = "Vol " + order.dealtAmountS.description
        } else if order.originalOrder.side.lowercased() == "buy" {
            volumeLabel.text = "Vol " + order.dealtAmountB.description
        }
        volumeLabel.setSubTitleDigitFont()
    }
    
    func setupPriceLabel(order: Order) {
        var limit: Double = 0
        let pair = order.originalOrder.market.components(separatedBy: "-")
        if let price = PriceDataManager.shared.getPrice(of: pair[1]) {
            if order.originalOrder.side.lowercased() == "sell" {
                limit = order.originalOrder.amountBuy / order.originalOrder.amountSell
            } else if order.originalOrder.side.lowercased() == "buy" {
                limit = order.originalOrder.amountSell / order.originalOrder.amountBuy
            }
            priceLabel.text = limit.description
            displayLabel.text = (limit * price).currency
        } else {
            displayLabel.text = "--"
        }
        priceLabel.setTitleDigitFont()
        displayLabel.setSubTitleDigitFont()
    }
    
    func setupOrderTypeLabel(order: Order) {
        orderTypeLabel.text = order.originalOrder.side.capitalized
        orderTypeLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 10)
        orderTypeLabel.borderWidth = 0.5
        if order.originalOrder.side == "buy" {
            orderTypeLabel.backgroundColor = .success
            orderTypeLabel.textColor = UIColor.text1
        } else if order.originalOrder.side == "sell" {
            orderTypeLabel.backgroundColor = .fail
            orderTypeLabel.textColor = UIColor.text1
        }
        orderTypeLabel.layer.cornerRadius = 2.0
        orderTypeLabel.layer.masksToBounds = true
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
