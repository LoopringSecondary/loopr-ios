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

class PlaceOrderConfirmationViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var confirmWidth: NSLayoutConstraint!
    @IBOutlet weak var declineWidth: NSLayoutConstraint!
    
    var order: OriginalOrder?
    var type: TradeType = .buy
    var price: String = "0.0"
    var message: String = ""
    var expire: OrderExpire = .oneHour
    var verifyInfo: [String: Double]?
    var isSigning: Bool = false
    
    // Labels
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()
    // Price
    var priceLabel: UILabel = UILabel()
    var priceValueLabel: UILabel = UILabel()
    var priceTipLabel: UILabel = UILabel()
    var priceUnderline: UIView = UIView()
    // Expires
    var expiresTipLabel: UILabel = UILabel()
    var expiresInfoLabel: UILabel = UILabel()
    var expiresUnderline: UIView = UIView()
    // LRC Fee
    var feeTipLabel: UILabel = UILabel()
    var feeInfoLabel: UILabel = UILabel()
    var feeUnderline: UIView = UIView()
    // Margin
    var marginTipLabel: UILabel = UILabel()
    var marginInfoLabel: UILabel = UILabel()
    var marginUnderline: UIView = UIView()
    // Total
    var totalTipLabel: UILabel = UILabel()
    var totalInfoLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        if let order = self.order {
            setupPrice(order: order)
            setupRows(order: order)
        }
        setupButtons()
    }
    
    func setupPrice(order: OriginalOrder) {
        guard isSigning else { return }
        if order.side == "buy" {
            self.price = (order.amountBuy / order.amountSell).withCommas()
        } else if order.side == "sell" {
            self.price = (order.amountSell / order.amountBuy).withCommas()
        }
    }
    
    func setupButtons() {
        if isSigning {
            let width = (UIScreen.main.bounds.width - 45) / 2
            confirmWidth.constant = width
            declineWidth.constant = width
            confirmationButton.title = NSLocalizedString("Accept", comment: "")
            declineButton.isHidden = false
            declineButton.title = NSLocalizedString("Decline", comment: "")
            declineButton.setupRoundWhite()
        } else {
            confirmationButton.title = NSLocalizedString("Confirmation", comment: "")
        }
        confirmationButton.setupRoundBlack()
    }
  
    func setupRows(order: OriginalOrder) {
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        let paddingTop: CGFloat = 50
        
        // labels
        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: paddingTop, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenSView)
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: paddingTop, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenBView)
        tokenSView.update(title: NSLocalizedString("You are selling", comment: ""), symbol: order.tokenSell, amount: order.amountSell)
        tokenBView.update(title: NSLocalizedString("You are buying", comment: ""), symbol: order.tokenBuy, amount: order.amountBuy)
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32*UIStyleConfig.scale, height: 32*UIStyleConfig.scale)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        scrollView.addSubview(arrowRightImageView)
        
        // 1st row: price
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        priceLabel.text = NSLocalizedString("Price", comment: "")
        priceLabel.frame = CGRect(x: padding, y: tokenSView.frame.maxY + padding*3, width: 150, height: 40)
        scrollView.addSubview(priceLabel)
        
        priceTipLabel.text = "(" + NSLocalizedString("Irrational", comment: "") + ")"
        priceTipLabel.textColor = .red
        priceTipLabel.textAlignment = .right
        priceTipLabel.font = FontConfigManager.shared.getLabelFont()
        priceTipLabel.frame = CGRect(x: screenWidth - padding - 100, y: priceLabel.frame.minY, width: 100, height: 40)
        priceTipLabel.isHidden = true
        scrollView.addSubview(priceTipLabel)
        
        priceValueLabel.font = FontConfigManager.shared.getLabelFont()
        let tradingPair = self.type == .buy ? "\(order.tokenBuy)/\(order.tokenSell)" : "\(order.tokenSell)/\(order.tokenBuy)"
        priceValueLabel.text = "\(price) \(tradingPair)"
        priceValueLabel.textAlignment = .right
        if !validateRational() {
            priceTipLabel.isHidden = false
            priceValueLabel.frame = CGRect(x: priceTipLabel.frame.minX - 200, y: priceLabel.frame.minY, width: 200, height: 40)
        } else {
            priceValueLabel.frame = CGRect(x: UIScreen.main.bounds.width - 15 - 200, y: priceLabel.frame.minY, width: 200, height: 40)
        }
        scrollView.addSubview(priceValueLabel)
        
        priceUnderline.frame = CGRect(x: padding, y: priceLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        priceUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(priceUnderline)
        
        // 2nd row: expires
        expiresTipLabel.font = FontConfigManager.shared.getLabelFont()
        expiresTipLabel.text = NSLocalizedString("Order Expires in", comment: "")
        expiresTipLabel.frame = CGRect(x: padding, y: priceLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(expiresTipLabel)
        expiresInfoLabel.font = FontConfigManager.shared.getLabelFont()
        expiresInfoLabel.text = self.expire.description
        expiresInfoLabel.textAlignment = .right
        expiresInfoLabel.frame = CGRect(x: padding + 150, y: expiresTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(expiresInfoLabel)
        expiresUnderline.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        expiresUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(expiresUnderline)
        
        // 3rd row: lrc fee
        feeTipLabel.font = FontConfigManager.shared.getLabelFont()
        feeTipLabel.text = NSLocalizedString("Trading Fee", comment: "")
        feeTipLabel.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(feeTipLabel)
        feeInfoLabel.font = FontConfigManager.shared.getLabelFont()
        if let price = PriceDataManager.shared.getPrice(of: "LRC") {
            let display = (order.lrcFee * price).currency
            feeInfoLabel.text = String(format: "%0.3f LRC(≈ \(display))", order.lrcFee)
        }
        feeInfoLabel.textAlignment = .right
        feeInfoLabel.frame = CGRect(x: padding + 150, y: feeTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(feeInfoLabel)
        feeUnderline.frame = CGRect(x: padding, y: feeTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        feeUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(feeUnderline)
        
        // 4th row: margin split
        marginTipLabel.font = FontConfigManager.shared.getLabelFont()
        marginTipLabel.text = NSLocalizedString("Margin Split", comment: "")
        marginTipLabel.frame = CGRect(x: padding, y: feeTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(marginTipLabel)
        marginInfoLabel.font = FontConfigManager.shared.getLabelFont()
        marginInfoLabel.text = SettingDataManager.shared.getMarginSplitDescription()
        marginInfoLabel.textAlignment = .right
        marginInfoLabel.frame = CGRect(x: padding + 150, y: marginTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(marginInfoLabel)
        marginUnderline.frame = CGRect(x: padding, y: marginTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        marginUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(marginUnderline)
        
        // 5th row: total
        totalTipLabel.font = FontConfigManager.shared.getLabelFont()
        totalTipLabel.text = NSLocalizedString("Total", comment: "")
        totalTipLabel.frame = CGRect(x: padding, y: marginTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(totalTipLabel)
        totalInfoLabel.font = FontConfigManager.shared.getLabelFont()
        totalInfoLabel.text = (order.side.lowercased() == "buy" ? order.amountBuy.description + " " + order.tokenBuy : order.amountSell.description + " " + order.tokenSell)
        totalInfoLabel.textAlignment = .right
        totalInfoLabel.frame = CGRect(x: padding + 150, y: totalTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(totalInfoLabel)
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: totalTipLabel.frame.maxY + padding)
    }

    func validateRational() -> Bool {
        let pair = TradeDataManager.shared.tradePair
        if let price = Double(self.price),
            let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            let header = NSLocalizedString("Your price is irrational, ", comment: "")
            let footer = NSLocalizedString("Do you wish to continue trading with the price?", comment: "")
            let messageA = NSLocalizedString("which may cause your asset wastage! ", comment: "")
            let messageB = NSLocalizedString("which may cause your order abolished! ", comment: "")
            if type == .buy {
                if price < 0.8 * market.balance {
                    self.message = header + messageB + footer
                    return false
                } else if price > 1.2 * market.balance {
                    self.message = header + messageA + footer
                    return false
                }
            } else {
                if price < 0.8 * market.balance {
                    self.message = header + messageA + footer
                    return false
                } else if price > 1.2 * market.balance {
                    self.message = header + messageB + footer
                    return false
                }
            }
            return true
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleOrder() {
        if !priceTipLabel.isHidden {
            let alert = UIAlertController(title: NSLocalizedString("Please Pay Attention", comment: ""), message: self.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.verifyInfo = PlaceOrderDataManager.shared.verify(order: self.order!)
                    self.handleVerifyInfo()
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.verifyInfo = PlaceOrderDataManager.shared.verify(order: order!)
            self.handleVerifyInfo()
        }
    }
    
    func handleSigning() {
        let manager = PlaceOrderDataManager.shared
        guard let hash = manager.signHash, let order = manager.signOrder else { return }
        manager._authorize { (_, error) in
            guard error == nil else { return }
            manager._submitOrder(order, completion: { (_, error) in
                guard error == nil else { return }
                LoopringAPIRequest.updateSignMessage(hash: hash, status: .accept, completionHandler: self.completion)
            })
        }
    }

    @IBAction func pressedConfirmationButton(_ sender: Any) {
        if self.isSigning {
            handleSigning()
        } else if self.order != nil {
            handleOrder()
        }
    }
    
    @IBAction func pressedDeclineButton(_ sender: UIButton) {
        guard isSigning, let hash = PlaceOrderDataManager.shared.signHash else { return }
        LoopringAPIRequest.updateSignMessage(hash: hash, status: .reject) { (_, _) in
            self.navigationController?.popViewController(animated: true)
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
            pushController(orderHash: nil)
        }
    }
    
    func pushController(orderHash: String?) {
        let viewController = ConfirmationResultViewController()
        viewController.orderHash = orderHash
        viewController.verifyInfo = self.verifyInfo
        viewController.order = isSigning ? PlaceOrderDataManager.shared.signOrder : order
        self.navigationController?.pushViewController(viewController, animated: true)
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
            var error: NSError? = nil
            let approve = GethBigInt.generate(valueInEther: Double(INT64_MAX), symbol: token)!
            let delegateAddress = GethNewAddressFromHex(RelayAPIConfiguration.delegateAddress, &error)!
            let tokenAddress = GethNewAddressFromHex(toAddress, &error)!
            SendCurrentAppWalletDataManager.shared._approve(tokenAddress: tokenAddress, delegateAddress: delegateAddress, tokenAmount: approve, completion: complete)
        }
    }
    
    func approveTwice(token: String) {
        if let toAddress = TokenDataManager.shared.getAddress(by: token) {
            var error: NSError? = nil
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
    
    func completion(_ orderHash: String?, _ error: Error?) {
        SVProgressHUD.dismiss()
        guard error == nil && orderHash != nil else {
            DispatchQueue.main.async {
                print("BuyViewController \(error.debugDescription)")
                let banner = NotificationBanner.generate(title: String(describing: error), style: .danger)
                banner.duration = 10
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            self.pushController(orderHash: orderHash!)
        }
    }
}
