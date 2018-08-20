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

class TradeConfirmationViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tokenSell: UIView!
    @IBOutlet weak var tokenBuy: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var LRCFeeLabel: UILabel!
    @IBOutlet weak var LRCFeeValueLabel: UILabel!
    @IBOutlet weak var marginSplitLabel: UILabel!
    @IBOutlet weak var marginSplitValueLabel: UILabel!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var validValueLabel: UILabel!
    @IBOutlet weak var gasInfoImage: UIImageView!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
        self.modalPresentationStyle = .custom
        self.navigationItem.title = LocalizedString("Trade_Confirm", comment: "")
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
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
        priceLabel.setTitleCharFont()
        priceValueLabel.setTitleDigitFont()
        
        // Trading Fee
        LRCFeeLabel.text = LocalizedString("Trading Fee", comment: "")
        LRCFeeLabel.setTitleCharFont()
        LRCFeeValueLabel.setTitleDigitFont()
        
        // Margin Split
        marginSplitLabel.text = LocalizedString("Margin Split", comment: "")
        marginSplitLabel.setTitleCharFont()
        marginSplitValueLabel.text = SettingDataManager.shared.getMarginSplitDescription()
        marginSplitValueLabel.setTitleDigitFont()
        
        // TTL label
        validLabel.setTitleCharFont()
        validLabel.text = LocalizedString("Time to Live", comment: "")
        validValueLabel.setTitleDigitFont()
        
        // Gas label
        gasTipLabel.setSubTitleCharFont()
        gasTipLabel.text = LocalizedString("GAS_TIP", comment: "")
        
        // Button
        placeOrderButton.setTitle(LocalizedString("Place Order", comment: ""), for: .normal)
        placeOrderButton.setupPrimary(height: 44)
        cancelButton.setTitle(LocalizedString("Cancel", comment: ""), for: .normal)
        
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
            LRCFeeValueLabel.text = "\(order.lrcFee.withCommas(3))LRC ≈ \(total)"
        }
        marginSplitValueLabel.text = SettingDataManager.shared.getMarginSplitDescription()
        let since = DateUtil.convertToDate(UInt(order.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validValueLabel.text = "\(since) ~ \(until)"
    }
    
    @IBAction func pressedPlaceOrderButton(_ sender: UIButton) {
        self.verifyInfo = TradeDataManager.shared.verify(order: order!)
        self.handleVerifyInfo()
        P2POrderHistoryDataManager.shared.shouldReloadData = true
    }
}

extension TradeConfirmationViewController {
    
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
        self.close(false)
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
                self.pushReviewController()
            } else {
                self.pushCompleteController()
            }
        }
    }
}
