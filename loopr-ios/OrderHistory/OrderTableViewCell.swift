//
//  OrderTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
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
    var buttonColor: UIColor?
    var pressedCancelButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.theme_backgroundColor = GlobalPicker.backgroundColor
        self.baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        self.baseView.applyShadow()
        cancelButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 14)
        buttonColor = cancelButton.currentTitleColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        }
    }
    
    func update() {
        guard let order = self.order else { return }
        setupTradingPairlabel(order: order)
        setupVolumeLabel(order: order)
        setupPriceLabel(order: order)
        setupOrderTypeLabel(order: order)
        setupCancelButton(order: order)
        setupOrderDate(order: order)
    }
    
    func setupCancelButton(order: Order) {
        let (flag, text) = getOrderStatus(order: order)
        cancelButton.isEnabled = flag
        cancelButton.title = text
    }
    
    func getOrderStatus(order: Order) -> (Bool, String) {
        if order.orderStatus == .opened {
            let cancelledAll = UserDefaults.standard.bool(forKey: UserDefaultsKeys.cancelledAll.rawValue)
            if cancelledAll || isOrderCancelling(order: order) {
                cancelButton.setTitleColor(.pending, for: .normal)
                return (false, LocalizedString("Cancelling", comment: ""))
            } else {
                cancelButton.setTitleColor(buttonColor, for: .normal)
                return (true, LocalizedString("Cancel", comment: ""))
            }
        } else if order.orderStatus == .cancelled || order.orderStatus == .expire {
            cancelButton.setTitleColor(.text1, for: .normal)
        } else if order.orderStatus == .finished {
            cancelButton.setTitleColor(.success, for: .normal)
        }
        return (false, order.orderStatus.description)
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
            volumeLabel.text = order.dealtAmountS.withCommas()
            volumeLabel.textColor = .fail
        } else if order.originalOrder.side.lowercased() == "buy" {
            volumeLabel.textColor = .success
        }
        volumeLabel.font = FontConfigManager.shared.getDigitalFont(size: 12)
    }
    
    func setupPriceLabel(order: Order) {
        var ratio: Double = 0
        let token = order.originalOrder.market.components(separatedBy: "-")[0]
        if order.originalOrder.side.lowercased() == "sell" {
            ratio = order.originalOrder.amountBuy / order.originalOrder.amountSell
        } else if order.originalOrder.side.lowercased() == "buy" {
            ratio = order.originalOrder.amountSell / order.originalOrder.amountBuy
        }
        priceLabel.text = ratio.withCommas()
        priceLabel.setSubTitleDigitFont()
        displayLabel.text = token
        displayLabel.setTitleDigitFont()
    }
    
    func setupOrderTypeLabel(order: Order) {
        orderTypeLabel.text = order.originalOrder.side.capitalized
        orderTypeLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 10)
        orderTypeLabel.borderWidth = 0.5
        if order.originalOrder.side == "buy" {
            orderTypeLabel.backgroundColor = .success
            orderTypeLabel.textColor = .white
        } else if order.originalOrder.side == "sell" {
            orderTypeLabel.backgroundColor = .fail
            orderTypeLabel.textColor = .white
        }
        orderTypeLabel.layer.cornerRadius = 2.0
        orderTypeLabel.layer.masksToBounds = true
    }
    
    func setupOrderDate(order: Order) {
        dateLabel.setSubTitleDigitFont()
        let since = DateUtil.convertToDate(UInt(order.originalOrder.validSince), format: "yyyy-MM-dd HH:mm")
        dateLabel.text = since
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
