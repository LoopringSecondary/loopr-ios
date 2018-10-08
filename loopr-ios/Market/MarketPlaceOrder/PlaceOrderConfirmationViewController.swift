//
//  PlaceOrderConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import SVProgressHUD
import NotificationBannerSwift
import Crashlytics

class PlaceOrderConfirmationViewController: UIViewController, UIScrollViewDelegate {

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
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var cellA: UIView!
    @IBOutlet weak var cellB: UIView!
    @IBOutlet weak var cellD: UIView!
    
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var priceTailing: NSLayoutConstraint!
    
    var tokenSView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBView: TradeViewOnlyViewController = TradeViewOnlyViewController()

    var order: OriginalOrder?
    var price: String? = "0.0"
    var message: String = ""
    var verifyInfo: [String: Double]?
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    var isSigning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        containerView.applyShadow()

        // TokenView
        tokenSView.view.frame = CGRect(x: 0, y: 0, width: tokenSell.frame.width, height: tokenSell.frame.height)
        tokenSell.addSubview(tokenSView.view)
        tokenSView.view.bindFrameToAnotherView(anotherView: tokenSell)
        
        tokenBView.view.frame = CGRect(x: 0, y: 0, width: tokenBuy.frame.width, height: tokenBuy.frame.height)
        tokenBuy.addSubview(tokenBView.view)
        tokenBView.view.bindFrameToAnotherView(anotherView: tokenBuy)
        
        // Price label
        priceLabel.text = LocalizedString("Price", comment: "")
        priceLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        priceLabel.theme_textColor = GlobalPicker.textLightColor
        
        priceValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        priceValueLabel.theme_textColor = GlobalPicker.textColor
        
        priceTipLabel.textColor = UIColor.fail
        priceTipLabel.text = LocalizedString("Irrational", comment: "")
        priceTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        priceTipLabel.theme_textColor = GlobalPicker.textColor
        
        if !validateRational() {
            priceTipLabel.isHidden = false
            if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" || SettingDataManager.shared.getCurrentLanguage().name  == "zh-Hant" {
                priceTailing.constant = 104
            } else {
                priceTailing.constant = 94
            }
        } else {
            priceTipLabel.isHidden = true
            priceTailing.constant = 20
        }
        
        // Trading Fee
        LRCFeeLabel.text = LocalizedString("Trading Fee", comment: "")
        LRCFeeLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        LRCFeeLabel.theme_textColor = GlobalPicker.textLightColor
        
        LRCFeeValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        LRCFeeValueLabel.theme_textColor = GlobalPicker.textColor

        // TTL label
        validLabel.text = LocalizedString("Expiration Time", comment: "")
        validLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        validLabel.theme_textColor = GlobalPicker.textLightColor
        
        validValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        validValueLabel.theme_textColor = GlobalPicker.textColor
        
        // Gas label
        gasTipLabel.text = LocalizedString("GAS_TIP", comment: "")
        gasTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        gasTipLabel.theme_textColor = GlobalPicker.textLightColor

        let cells = [cellA, cellB, cellD]
        cells.forEach { $0?.theme_backgroundColor = ColorPicker.cardBackgroundColor }
        cellBackgroundView.theme_backgroundColor = ColorPicker.cardHighLightColor
        
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
        setupButtons()
    }
    
    func isBuyingOrder() -> Bool {
        var result: Bool = false
        if self.order?.side == "buy" {
            result = true
        } else if self.order?.side == "sell" {
            result = false
        }
        return result
    }
    
    func validateRational() -> Bool {
        let pair = PlaceOrderDataManager.shared.market.name
        if let price = self.price, let value = Double(price),
            let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            let header = LocalizedString("Your price is irrational, ", comment: "")
            let footer = LocalizedString("Do you wish to continue trading or signing with the price?", comment: "")
            let messageA = LocalizedString("which may cause your asset wastage! ", comment: "")
            let messageB = LocalizedString("which may cause your order abolished! ", comment: "")
            if isBuyingOrder() {
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

    func setupButtons() {
        if isSigning {
            confirmationButton.title = LocalizedString("Accept", comment: "")
            declineButton.isHidden = false
            declineButton.title = LocalizedString("Decline", comment: "")
            declineButton.setupSecondary(height: 44)
        } else {
            confirmationButton.title = LocalizedString("Confirm", comment: "")
        }
        confirmationButton.setupPrimary(height: 44)

        cancelButton.setTitle(LocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        cancelButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 16)
    }
    
    func updateLabels(order: OriginalOrder) {
        tokenSView.update(type: .sell, symbol: order.tokenSell, amount: order.amountSell)
        tokenBView.update(type: .buy, symbol: order.tokenBuy, amount: order.amountBuy)

        let price = order.amountBuy / order.amountSell
        if order.side == "buy" {
            let value = 1 / price
            priceValueLabel.text = "\(value.withCommas(12).trailingZero()) \(order.tokenBuy)/\(order.tokenSell)"
        } else {
            let value = price
            priceValueLabel.text = "\(value.withCommas(12).trailingZero()) \(order.tokenSell)/\(order.tokenBuy)"
        }

        if let price = PriceDataManager.shared.getPrice(of: "LRC") {
            let total = (price * order.lrcFee).currency
            LRCFeeValueLabel.text = "\(order.lrcFee.withCommas(3)) LRC ≈ \(total)"
        }
        // let since = DateUtil.convertToDate(UInt(order.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validValueLabel.text = "\(until)"
    }
    
    func close(_ animated: Bool = true) {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: animated, completion: {
        })
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        close()
    }
    
    @IBAction func pressedCancelButton(_ sender: UIButton) {
        self.close()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        if containerView.frame.contains(location) {
            return false
        }
        return true
    }
    
    func handleOrder() {
        if !priceTipLabel.isHidden {
            let alert = UIAlertController(title: LocalizedString("Please Pay Attention", comment: ""), message: self.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    SVProgressHUD.show(withStatus: LocalizedString("Submitting order", comment: "") + "...")
                    self.verifyInfo = PlaceOrderDataManager.shared.verify(order: self.order!)
                    self.handleVerifyInfo()
                }
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            SVProgressHUD.show(withStatus: LocalizedString("Submitting order", comment: "") + "...")
            self.verifyInfo = PlaceOrderDataManager.shared.verify(order: order!)
            self.handleVerifyInfo()
        }
    }
    
    func doSigning() {
        let manager = AuthorizeDataManager.shared
        guard let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address, let hash = manager.submitHash, let order = manager.submitOrder else { return }
        guard address.lowercased() == order.address.lowercased() else {
            let errorMessage = LocalizedString("Signer address does NOT match the order's, please transfer and try again later", comment: "")
            let error = NSError(domain: "approving", code: 0, userInfo: ["message": errorMessage])
            self.completion(nil, error)
            return
        }
        SVProgressHUD.show(withStatus: LocalizedString("Approving authorization", comment: "") + "...")
        manager._authorizeOrder { (_, error) in
            guard error == nil else {
                LoopringAPIRequest.notifyStatus(hash: hash, status: .txFailed, completionHandler: { (_, _) in })
                self.complete(nil, error!)
                return
            }
            PlaceOrderDataManager.shared._submitOrder(order, completion: { (orderHash, error) in
                guard let orderHash = orderHash, error == nil else {
                    self.complete(nil, error!)
                    return
                }
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.cancelledAll.rawValue)
                LoopringAPIRequest.notifyStatus(hash: hash, status: .accept, completionHandler: { (_, error) in
                    self.completion(orderHash, error)
                })
            })
        }
    }
    
    func handleSigning() {
        self.doSigning()
    }

    @IBAction func pressedConfirmationButton(_ sender: Any) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to confirm the order", comment: "")) { (error) in
                guard error == nil else {
                    return
                }
                if self.isSigning {
                    self.handleSigning()
                } else if self.order != nil {
                    self.handleOrder()
                }
            }
        } else {
            if self.isSigning {
                self.handleSigning()
            } else if self.order != nil {
                self.handleOrder()
            }
        }
    }
    
    @IBAction func pressedDeclineButton(_ sender: UIButton) {
        guard isSigning, let hash = AuthorizeDataManager.shared.submitHash else { return }
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            // TODO: For decline the order, do we still need to ask authentication?
            AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to decline the order", comment: "")) { (error) in
                guard error == nil else {
                    return
                }
                LoopringAPIRequest.notifyStatus(hash: hash, status: .reject) { (_, _) in
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        } else {
            LoopringAPIRequest.notifyStatus(hash: hash, status: .reject) { (_, _) in
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension PlaceOrderConfirmationViewController {

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
            if needApprove() {
                approve()
            } else {
                submit()
            }
        } else {
            SVProgressHUD.dismiss()
            pushController(orderHash: nil)
        }
    }
    
    func pushController(orderHash: String?) {
        self.close(false)
        let viewController = ConfirmationResultViewController()
        viewController.verifyInfo = self.verifyInfo
        viewController.order = isSigning ? AuthorizeDataManager.shared.submitOrder : order
        self.parentNavController?.pushViewController(viewController, animated: true)
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
        PlaceOrderDataManager.shared._submitOrder(self.order!) { (orderHash, error) in
            if orderHash != nil && error == nil {
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.cancelledAll.rawValue)
            }
            self.completion(orderHash, error)
        }
    }
    
    // complete used in getting authorization. After this complete succeeds, it should calls submit()
    func complete(_ txHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                print("BuyViewController \(error.debugDescription)")
                let banner = NotificationBanner.generate(title: String(describing: error), style: .danger)
                banner.duration = 10
                banner.show()
            }
            return
        }
        submit()
    }
    
    // completion for submitting a market order
    func completion(_ orderHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        guard error == nil && orderHash != nil else {
            Answers.logCustomEvent(withName: "Submit Market Order v1",
                                   customAttributes: [
                                   "success": "false"])

            DispatchQueue.main.async {
                print("PlaceOrderConfirmationViewController \(error.debugDescription)")
                let message: String = (error! as NSError).userInfo["message"] as? String ?? String(describing: error)
                let banner = NotificationBanner.generate(title: message, style: .danger)
                banner.duration = 10
                banner.show()
            }
            return
        }

        Answers.logCustomEvent(withName: "Submit Market Order v1",
                               customAttributes: [
                               "success": "true"])

        DispatchQueue.main.async {
            self.pushController(orderHash: orderHash!)
        }
    }
}
