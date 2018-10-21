//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import SVProgressHUD
import NotificationBannerSwift
import Crashlytics

class TradeConfirmationViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tokenSell: UIView!
    @IBOutlet weak var tokenBuy: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var priceTipLabel: UILabel!
    @IBOutlet weak var LRCFeeLabel: UILabel!
    @IBOutlet weak var LRCFeeValueLabel: UILabel!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var validValueLabel: UILabel!
    @IBOutlet weak var gasInfoImage: UIImageView!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var placeOrderButton: GradientButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var cellA: UIView!
    @IBOutlet weak var cellB: UIView!
    @IBOutlet weak var cellD: UIView!
    
    @IBOutlet weak var priceTailing: NSLayoutConstraint!
    
    var tokenSView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    
    var message: String?
    var order: OriginalOrder?
    var verifyInfo: [String: Double]?
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setBackButton()
        self.navigationItem.title = LocalizedString("Trade_Confirm", comment: "")

        view.backgroundColor = UIColor.clear
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        containerView.applyShadow()
        
        let cells = [cellA, cellB, cellD]
        cells.forEach { $0?.theme_backgroundColor = ColorPicker.cardBackgroundColor }
        cellBackgroundView.theme_backgroundColor = ColorPicker.cardHighLightColor
        
        // TokenView
        tokenSView.view.frame = CGRect(x: 0, y: 0, width: tokenSell.frame.width, height: tokenSell.frame.height)
        tokenSell.addSubview(tokenSView.view)
        tokenSView.view.bindFrameToAnotherView(anotherView: tokenSell)
        
        tokenBView.view.frame = CGRect(x: 0, y: 0, width: tokenBuy.frame.width, height: tokenBuy.frame.height)
        tokenBuy.addSubview(tokenBView.view)
        tokenBView.view.bindFrameToAnotherView(anotherView: tokenBuy)
        
        // Price label
        priceLabel.text = LocalizedString("Price", comment: "")
        priceLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        priceLabel.theme_textColor = GlobalPicker.textLightColor

        priceValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        priceValueLabel.theme_textColor = GlobalPicker.textColor
        
        priceTipLabel.textColor = UIColor.fail
        priceTipLabel.text = LocalizedString("Irrational", comment: "")
        priceTipLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        priceTipLabel.theme_textColor = GlobalPicker.textColor
        
        if !validateRational() {
            priceTipLabel.isHidden = false
            priceTailing.constant = 104
        } else {
            priceTipLabel.isHidden = true
            priceTailing.constant = 20
        }
        
        // Trading Fee
        LRCFeeLabel.text = LocalizedString("Trading Fee", comment: "")
        LRCFeeLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        LRCFeeLabel.theme_textColor = GlobalPicker.textLightColor
        
        LRCFeeValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        LRCFeeValueLabel.theme_textColor = GlobalPicker.textColor

        // TTL label
        validLabel.text = LocalizedString("Expiration Time", comment: "")
        validLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        validLabel.theme_textColor = GlobalPicker.textLightColor
        
        validValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        validValueLabel.theme_textColor = GlobalPicker.textColor

        // Gas label
        gasTipLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        gasTipLabel.theme_textColor = GlobalPicker.textLightColor
        gasTipLabel.text = LocalizedString("GAS_TIP", comment: "")
        
        // Button
        placeOrderButton.setTitle(LocalizedString("Place Order", comment: ""), for: .normal)
        placeOrderButton.setPrimaryColor()
        
        // Cancel button
        cancelButton.setTitle(LocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        cancelButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 16)

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let order = self.order {
            updateLabels(order: order)
        }
    }
    
    func validateRational() -> Bool {
        guard let order = self.order else { return true }
        let pair = TradeDataManager.shared.tradePair.replacingOccurrences(of: "/", with: "-")  // "LRC-WETH"
        let price = order.amountBuy / order.amountSell
        let value = order.side == "buy" ? 1 / price : price
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            let header = LocalizedString("Your price is irrational, ", comment: "")
            let footer = LocalizedString("Do you wish to continue trading or signing with the price?", comment: "")
            let messageA = LocalizedString("which may cause your asset wastage! ", comment: "")
            let messageB = LocalizedString("which may cause your order abolished! ", comment: "")
            if order.side == "buy" {
                if value < 0.8 * market.balance {
                    self.message = header + messageB + footer
                    return false
                } else if value > 1.2 * market.balance {
                    self.message = header + messageA + footer
                    return false
                }
            } else {
                if value < 0.8 * market.balance {
                    self.message = header + messageA + footer
                    return false
                } else if value > 1.2 * market.balance {
                    self.message = header + messageB + footer
                    return false
                }
            }
            return true
        }
        return true
    }
    
    func close(_ animated: Bool = true) {
        if let navigation = self.navigationController {
            for controller in navigation.viewControllers as Array {
                if controller.isKind(of: WalletViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        } else {
            if let closure = self.dismissClosure {
                closure()
            }
            self.dismiss(animated: animated, completion: {
            })
        }
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
    
    @IBAction func pressedCancelButton(_ sender: UIButton) {
        self.close()
    }
    
    func updateLabels(order: OriginalOrder) {
        tokenBView.update(type: .buy, symbol: order.tokenBuy, amount: order.amountBuy)
        tokenSView.update(type: .sell, symbol: order.tokenSell, amount: order.amountSell)
        let price = order.amountBuy / order.amountSell
        let value = order.side == "buy" ? 1 / price : price
        priceValueLabel.text = "\(value.withCommas()) \(order.market)"
        if let price = PriceDataManager.shared.getPrice(of: "LRC") {
            let total = (price * order.lrcFee).currency
            LRCFeeValueLabel.text = "\(order.lrcFee.withCommas(3)) LRC ≈ \(total)"
        }
        // let since = DateUtil.convertToDate(UInt(order.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validValueLabel.text = "\(until)"
    }
    
    @IBAction func pressedPlaceOrderButton(_ sender: UIButton) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to place the order", comment: "")) { (error) in
                guard error == nil else {
                    return
                }
                self.authorizeToPlaceOrder()
            }
        } else {
            self.authorizeToPlaceOrder()
        }
    }
}

extension TradeConfirmationViewController {
    
    func authorizeToPlaceOrder() {
        if !priceTipLabel.isHidden {
            let alert = UIAlertController(title: LocalizedString("Please Pay Attention", comment: ""), message: self.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.verifyInfo = TradeDataManager.shared.verify(order: self.order!)
                    self.handleVerifyInfo()
                    P2POrderHistoryDataManager.shared.shouldReloadData = true
                }
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.verifyInfo = TradeDataManager.shared.verify(order: order!)
            self.handleVerifyInfo()
            P2POrderHistoryDataManager.shared.shouldReloadData = true
        }
    }
    
    func isTaker() -> Bool {
        return TradeDataManager.shared.isTaker
    }
    
    func isBalanceEnough() -> Bool {
        var result: Bool = true
        if let info = self.verifyInfo {
            result = !info.keys.contains(where: { (key) -> Bool in
                key.starts(with: "MINUS_")
            })
        }
        return result
    }
    
    func needApprove() -> Bool {
        var result: Bool = false
        if let info = self.verifyInfo {
            result = info.keys.contains(where: { (key) -> Bool in
                key.starts(with: "GAS_")
            })
        }
        return result
    }
    
    func handleVerifyInfo() {
        if isBalanceEnough() {
            SVProgressHUD.show(withStatus: LocalizedString("Processing the P2P order...", comment: ""))
            if needApprove() {
                approve()
            } else {
                submit()
            }
        } else {
            pushCompleteController()
        }
    }
    
    func pushCompleteController() {
        let controller = TradeCompleteViewController()
        controller.order = self.order
        controller.verifyInfo = self.verifyInfo
        controller.hidesBottomBarWhenPushed = true
        self.parentNavController?.pushViewController(controller, animated: true)
    }
    
    func pushReviewController() {
        self.close(true)
        let controller = TradeReviewViewController()
        controller.order = self.order
        self.parentNavController?.pushViewController(controller, animated: true)
    }
    
    func approve() {
        if let info = self.verifyInfo {
            for item in info {
                if item.key.starts(with: "GAS_") {
                    guard item.value == 1 || item.value == 2 else { return }
                    let token = item.key.components(separatedBy: "_")[1]
                    if item.value == 1 {
                        approveOnce(token: token)
                    } else {
                        approveTwice(token: token)
                    }
                }
            }
        }
    }
    
    func approveOnce(token: String) {
        if let toAddress = TokenDataManager.shared.getAddress(by: token) {
            var error: NSError?
            let approve = GethBigInt.generate(valueInEther: Double(INT64_MAX), symbol: token)!
            let delegateAddress = GethNewAddressFromHex(RelayAPIConfiguration.delegateAddress, &error)!
            let tokenAddress = GethNewAddressFromHex(toAddress, &error)!
            SendCurrentAppWalletDataManager.shared._approve(tokenAddress: tokenAddress, delegateAddress: delegateAddress, tokenAmount: approve, completion: complete)
        }
    }
    
    func approveTwice(token: String) {
        if let toAddress = TokenDataManager.shared.getAddress(by: token) {
            var error: NSError?
            var approve = GethBigInt.generate(valueInEther: 0, symbol: token)!
            let delegateAddress = GethNewAddressFromHex(RelayAPIConfiguration.delegateAddress, &error)!
            let tokenAddress = GethNewAddressFromHex(toAddress, &error)!
            SendCurrentAppWalletDataManager.shared._approve(tokenAddress: tokenAddress, delegateAddress: delegateAddress, tokenAmount: approve) { (txHash, error) in
                guard error == nil && txHash != nil else {
                    self.complete(nil, error!)
                    return
                }
                approve = GethBigInt.generate(valueInEther: Double(INT64_MAX), symbol: token)!
                SendCurrentAppWalletDataManager.shared._approve(tokenAddress: tokenAddress, delegateAddress: delegateAddress, tokenAmount: approve, completion: self.complete)
            }
        }
    }
    
    func submit() {
        if !isTaker() {
            PlaceOrderDataManager.shared._submitOrder(self.order!) { (orderHash, error) in
                guard error == nil && orderHash != nil else {
                    self.completion(nil, error!)
                    return
                }
                TradeDataManager.shared.startGetOrderStatus(of: self.order!.hash)
                self.completion(orderHash!, nil)
            }
        } else {
            PlaceOrderDataManager.shared._submitOrderForP2P(self.order!) { (orderHash, error) in
                guard error == nil && orderHash != nil else {
                    let errorCode = (error! as NSError).userInfo["message"] as! String
                    if let error = TradeDataManager.shared.generateErrorMessage(errorCode: errorCode) {
                        self.completion(nil, error)
                    }
                    return
                }
                TradeDataManager.shared._submitRing(completion: self.completion)
            }
        }
    }

    func complete(_ txHash: String?, _ error: Error?) {
        guard error == nil && txHash != nil else {
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                if let error = error as NSError?,
                    let json = error.userInfo["message"] as? JSON,
                    let message = json.string {
                    let banner = NotificationBanner.generate(title: message, style: .danger)
                    banner.duration = 5
                    banner.show()
                }
            }
            return
        }
        submit()
    }
    
    func completion(_ orderHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        guard error == nil && orderHash != nil else {
            Answers.logCustomEvent(withName: "Submit P2P Order v1",
                                   customAttributes: [
                                    "success": "false"])

            DispatchQueue.main.async {
                print("TradeViewController \(error.debugDescription)")
                let message = (error! as NSError).userInfo["message"] as! String
                let banner = NotificationBanner.generate(title: message, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            if !self.isTaker() {
                Answers.logCustomEvent(withName: "Submit P2P Order v1",
                                       customAttributes: [
                                       "success": "true",
                                       "isTaker": "false"])
                self.pushReviewController()
            } else {
                Answers.logCustomEvent(withName: "Submit P2P Order v1",
                                       customAttributes: [
                                       "success": "true",
                                       "isTaker": "true"])
                self.pushCompleteController()
            }
        }
    }
}
