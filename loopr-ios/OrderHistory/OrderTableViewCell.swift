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
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var secondLabelXLayoutContraint: NSLayoutConstraint!

    var order: Order?
    var buttonColor: UIColor?
    var pressedCancelButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.theme_backgroundColor = ColorPicker.backgroundColor
        self.baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        cancelButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 13)
        buttonColor = UIColor.theme
        
        priceLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        priceLabel.theme_textColor = GlobalPicker.textLightColor
        
        displayLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        displayLabel.theme_textColor = GlobalPicker.textColor
        
        volumeLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        volumeLabel.theme_textColor = GlobalPicker.textLightColor
        
        dateLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        dateLabel.theme_textColor = GlobalPicker.textLightColor
        
        let label2Width = LocalizedString("Amount/Filled", comment: "").textWidth(font: FontConfigManager.shared.getCharactorFont(size: 13))
        secondLabelXLayoutContraint.constant = (UIScreen.main.bounds.width-15*2)*0.5-label2Width*0.5
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = ColorPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        }
    }
    
    func update() {
        guard let order = self.order else { return }

        setupTradingPairlabel(order: order)
        setupPriceLabel(order: order)
        setupOrderTypeLabel(order: order)
        
        setupVolumeLabel(order: order)
        
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
                return (false, LocalizedString("Canceling", comment: ""))
            } else {
                cancelButton.setTitleColor(buttonColor, for: .normal)
                return (true, LocalizedString("Cancel", comment: ""))
            }
        } else if order.orderStatus == .cancelled || order.orderStatus == .expire {
            cancelButton.setTitleColor(.text2, for: .normal)
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
        tradingPairLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        tradingPairLabel.theme_textColor = GlobalPicker.textColor
        tradingPairLabel.setMarket()
    }
    
    func setupVolumeLabel(order: Order) {
        if order.originalOrder.side.lowercased() == "sell" {
            displayLabel.text = order.originalOrder.amountSell.withCommas().trailingZero()
            volumeLabel.text = ((order.dealtAmountS/order.originalOrder.amountSell)*100).withCommas(0) + NumberFormatter().percentSymbol
        } else if order.originalOrder.side.lowercased() == "buy" {
            displayLabel.text = order.originalOrder.amountBuy.withCommas().trailingZero()
            volumeLabel.text = ((order.dealtAmountB/order.originalOrder.amountBuy)*100).withCommas(0) + NumberFormatter().percentSymbol
        }
        if order.orderStatus == .cancelled || order.orderStatus == .expire {
            volumeLabel.text = " - "
        } else if order.orderStatus == .finished {
            volumeLabel.text = "100%"
        }
    }
    
    func setupPriceLabel(order: Order) {
        let price = order.originalOrder.amountBuy / order.originalOrder.amountSell
        if order.originalOrder.side.lowercased() == "buy" {
            var value = (1 / price).withCommas(15).trailingZero()
            if value.count > 9 {
                value = (1 / price).withCommas(6)
            }
            priceLabel.text = "\(value.trailingZero())"
        } else {
            var value = (price).withCommas(15).trailingZero()
            if value.count > 9 {
                value = (price).withCommas(6)
            }
            priceLabel.text = "\(value.trailingZero())"
        }
    }
    
    func setupOrderTypeLabel(order: Order) {
        orderTypeLabel.font = FontConfigManager.shared.getBoldFont(size: 10)
        orderTypeLabel.borderWidth = 0.5
        if order.originalOrder.side == "buy" {
            orderTypeLabel.text = LocalizedString("B", comment: "")
            orderTypeLabel.backgroundColor = .success
            orderTypeLabel.textColor = .white
        } else if order.originalOrder.side == "sell" {
            orderTypeLabel.text = LocalizedString("S", comment: "")
            orderTypeLabel.backgroundColor = .fail
            orderTypeLabel.textColor = .white
        }
        orderTypeLabel.layer.cornerRadius = 2.0
        orderTypeLabel.layer.masksToBounds = true
    }
    
    func setupOrderDate(order: Order) {
        let since = DateUtil.convertToDate(UInt(order.originalOrder.validSince), format: "YYYY-MM-dd HH:mm")
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
        return 68+1
    }
}
