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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    // TODO: put the following UILabel and UIView to a UIView?
    var marginSplitLabel: UILabel = UILabel()
    var marginSplitValueLabel: UILabel = UILabel()
    
    var LRCFeeLabel: UILabel = UILabel()
    var LRCFeeValueLabel: UILabel = UILabel()
    var LRCFeeUnderLine: UIView = UIView()
    
    var priceLabel: UILabel = UILabel()
    var priceValueLabel: UILabel = UILabel()
    var priceTipLabel: UILabel = UILabel()
    var priceUnderLine: UIView = UIView()
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()
    
    var order: OriginalOrder?
    var verifyInfo: [String: Double]?
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Confirmation", comment: "")
        setBackButton()
        
        // Token View
        let paddingTop: CGFloat = 100
        let padding: CGFloat = 15
        let rowHeight: CGFloat = 40
        let rowPadding: CGFloat = 10
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: paddingTop, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenSView)
        
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: paddingTop, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenBView)
        
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32*UIStyleConfig.scale, height: 32*UIStyleConfig.scale)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        scrollView.addSubview(arrowRightImageView)
        
        // Price label
        priceLabel.text = LocalizedString("Price", comment: "")
        priceLabel.textColor = UIColor.black
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        priceLabel.frame = CGRect(x: padding, y: screenHeight * 0.57, width: 160, height: rowHeight)
        scrollView.addSubview(priceLabel)
        
        priceTipLabel.text = "(" + LocalizedString("Irrational", comment: "") + ")"
        priceTipLabel.textColor = .red
        priceTipLabel.textAlignment = .right
        priceTipLabel.font = FontConfigManager.shared.getLabelFont()
        priceTipLabel.frame = CGRect(x: screenWidth - padding - 100, y: priceLabel.frame.minY, width: 100, height: rowHeight)
        priceTipLabel.isHidden = true
        scrollView.addSubview(priceTipLabel)
        
        priceValueLabel.textColor = UIColor.black
        priceValueLabel.textAlignment = .right
        priceValueLabel.font = FontConfigManager.shared.getLabelFont()
        priceValueLabel.frame = CGRect(x: priceTipLabel.frame.minX - padding - 200, y: priceLabel.frame.minY, width: 200, height: rowHeight)
        scrollView.addSubview(priceValueLabel)
        
        priceUnderLine.frame = CGRect(x: padding, y: priceLabel.frame.maxY - 5, width: screenWidth - padding * 2, height: 1)
        priceUnderLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        scrollView.addSubview(priceUnderLine)
        
        // Trading Fee
        LRCFeeLabel.text = LocalizedString("Trading Fee", comment: "")
        LRCFeeLabel.textColor = UIColor.black
        LRCFeeLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeLabel.frame = CGRect(x: padding, y: priceValueLabel.frame.maxY + rowPadding, width: 160, height: rowHeight)
        scrollView.addSubview(LRCFeeLabel)
        
        LRCFeeValueLabel.textColor = UIColor.black
        LRCFeeValueLabel.textAlignment = .right
        LRCFeeValueLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeValueLabel.frame = CGRect(x: screenWidth - padding - 160, y: LRCFeeLabel.frame.minY, width: 160, height: rowHeight)
        scrollView.addSubview(LRCFeeValueLabel)
        
        LRCFeeUnderLine.frame = CGRect(x: padding, y: LRCFeeLabel.frame.maxY - 5, width: screenWidth - padding * 2, height: 1)
        LRCFeeUnderLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        scrollView.addSubview(LRCFeeUnderLine)
        
        // Margin Split
        marginSplitLabel.text = LocalizedString("Margin Split", comment: "")
        marginSplitLabel.textColor = UIColor.black
        marginSplitLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitLabel.frame = CGRect(x: padding, y: LRCFeeLabel.frame.maxY + rowPadding, width: 160, height: rowHeight)
        scrollView.addSubview(marginSplitLabel)
        
        marginSplitValueLabel.text = SettingDataManager.shared.getMarginSplitDescription()
        marginSplitValueLabel.textColor = UIColor.black
        marginSplitValueLabel.textAlignment = .right
        marginSplitValueLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitValueLabel.frame = CGRect(x: screenWidth - padding - 160, y: marginSplitLabel.frame.minY, width: 160, height: rowHeight)
        scrollView.addSubview(marginSplitValueLabel)
        
        scrollView.contentSize = CGSize(width: screenWidth, height: marginSplitLabel.frame.maxY + padding)
        
        // Button
        placeOrderButton.setTitle(LocalizedString("Place Order", comment: ""), for: .normal)
        placeOrderButton.setupSecondary()
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
    
    func updateLabels(order: OriginalOrder) {
        tokenSView.update(title: LocalizedString("You are selling", comment: ""), symbol: order.tokenSell, amount: order.amountSell)
        tokenBView.update(title: LocalizedString("You are buying", comment: ""), symbol: order.tokenBuy, amount: order.amountBuy)
        let value = order.amountSell / order.amountBuy
        priceValueLabel.text = "\(value.withCommas()) \(order.market)"
        priceValueLabel.frame = CGRect(x: UIScreen.main.bounds.width - 15 - 200, y: priceLabel.frame.minY, width: 200, height: 40)
        if let price = PriceDataManager.shared.getPrice(of: "LRC") {
            let total = (price * order.lrcFee).currency
            LRCFeeValueLabel.text = "\(order.lrcFee)LRC ≈ \(total)"
        }
        marginSplitValueLabel.text = SettingDataManager.shared.getMarginSplitDescription()
    }
    
    @IBAction func pressedPlaceOrderButton(_ sender: UIButton) {
        self.verifyInfo = TradeDataManager.shared.verify(order: order!)
        self.handleVerifyInfo()
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
            SVProgressHUD.show(withStatus: "正在撮合并提交P2P订单...")
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
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushReviewController() {
        let controller = TradeReviewViewController()
        controller.order = self.order
        self.navigationController?.pushViewController(controller, animated: true)
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
            PlaceOrderDataManager.shared._submitOrder(self.order!) { (orderHash, error) in
                guard error == nil && orderHash != nil else {
                    self.completion(nil, error!)
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
