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
    
    var order: OriginalOrder?
    var type: TradeType = .buy
    var price: String = "0.0"
    var expire: OrderExpire = .oneHour
    var verifyInfo: [String: Double]?
    
    // Labels
    var typeTipLabel: UILabel = UILabel()
    var iconView: IconView = IconView()
    var tokenImage: UIImageView = UIImageView()
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    // Price
    var priceTipLabel: UILabel = UILabel()
    var priceInfoLabel: UILabel = UILabel()
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
        confirmationButton.title = NSLocalizedString("Confirmation", comment: "")
        confirmationButton.setupRoundBlack()
        if let order = self.order {
            setupLabels()
            setupTokenView(order: order)
            setupOrderAmount(order: order)
            setupRows(order: order)
        }
    }
    
    func setupLabels() {
        typeTipLabel.textAlignment = .center
        typeTipLabel.text = (type == .buy ? NSLocalizedString("You are buying", comment: "") : NSLocalizedString("You are selling", comment: ""))
        typeTipLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        typeTipLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    func setupTokenView(order: OriginalOrder) {
        if order.side.lowercased() == "buy" {
            if let icon = UIImage(named: order.tokenBuy) {
                tokenImage.image = icon
                tokenImage.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = order.tokenBuy
                iconView.symbolLabel.text = order.tokenBuy
                tokenImage.isHidden = true
            }
        } else if order.side.lowercased() == "sell" {
            if let icon = UIImage(named: order.tokenSell) {
                tokenImage.image = icon
                tokenImage.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = order.tokenSell
                iconView.symbolLabel.text = order.tokenSell
                tokenImage.isHidden = true
            }
        }
    }
    
    func setupOrderAmount(order: OriginalOrder) {
        if order.side.lowercased() == "sell" {
            amountLabel.text = order.amountSell.description + " " + order.tokenSell
            if let price = PriceDataManager.shared.getPriceBySymbol(of: order.tokenSell) {
                displayLabel.text = (price * order.amountSell).currency
            }
        } else if order.side.lowercased() == "buy" {
            amountLabel.text = order.amountBuy.description + " " + order.tokenBuy
            if let price = PriceDataManager.shared.getPriceBySymbol(of: order.tokenBuy) {
                displayLabel.text = (price * order.amountBuy).currency
            }
        }
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 40)
        amountLabel.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        displayLabel.textAlignment = .center
        displayLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        displayLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    func setupRows(order: OriginalOrder) {
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        
        typeTipLabel.frame = CGRect(x: 0, y: 50, width: screenWidth, height: 40)
        scrollView.addSubview(typeTipLabel)

        let width = screenWidth * 0.2
        let rect = CGRect(x: screenWidth * 0.4, y: typeTipLabel.frame.maxY + 2*padding, width: width, height: width)
        iconView.frame = rect
        tokenImage.frame = rect
        iconView.layer.cornerRadius = width/2
        iconView.clipsToBounds = true
        scrollView.addSubview(iconView)
        scrollView.addSubview(tokenImage)
        
        amountLabel.frame = CGRect(x: 0, y: tokenImage.frame.maxY + 2*padding, width: screenWidth, height: 40)
        scrollView.addSubview(amountLabel)
        displayLabel.frame = CGRect(x: 0, y: amountLabel.frame.maxY + padding, width: screenWidth, height: 40)
        scrollView.addSubview(displayLabel)
        
        // 1st row: price
        priceTipLabel.font = FontConfigManager.shared.getLabelFont()
        priceTipLabel.text = NSLocalizedString("Price", comment: "")
        priceTipLabel.frame = CGRect(x: padding, y: displayLabel.frame.maxY + padding*3, width: 150, height: 40)
        scrollView.addSubview(priceTipLabel)
        priceInfoLabel.font = FontConfigManager.shared.getLabelFont()
        priceInfoLabel.text = self.price + " " + PlaceOrderDataManager.shared.market.description
        priceInfoLabel.textAlignment = .right
        priceInfoLabel.frame = CGRect(x: padding + 150, y: priceTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(priceInfoLabel)
        priceUnderline.frame = CGRect(x: padding, y: priceTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        priceUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(priceUnderline)
        
        // 2nd row: expires
        expiresTipLabel.font = FontConfigManager.shared.getLabelFont()
        expiresTipLabel.text = NSLocalizedString("Order Expires in", comment: "")
        expiresTipLabel.frame = CGRect(x: padding, y: priceTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(expiresTipLabel)
        expiresInfoLabel.font = FontConfigManager.shared.getLabelFont()
        expiresInfoLabel.text = self.expire.description
        expiresInfoLabel.textAlignment = .right
        expiresInfoLabel.frame = CGRect(x: padding + 150, y: expiresTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(expiresInfoLabel)
        expiresUnderline.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        expiresUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(expiresUnderline)
        
        // 3rd row: lrc fee
        feeTipLabel.font = FontConfigManager.shared.getLabelFont()
        feeTipLabel.text = NSLocalizedString("Trading Fee", comment: "")
        feeTipLabel.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(feeTipLabel)
        feeInfoLabel.font = FontConfigManager.shared.getLabelFont()
        if let price = PriceDataManager.shared.getPriceBySymbol(of: "LRC") {
            let display = (order.lrcFee * price).currency
            feeInfoLabel.text = String(format: "%0.5f LRC (≈ %.2f)", order.lrcFee, display)
        }
        feeInfoLabel.textAlignment = .right
        feeInfoLabel.frame = CGRect(x: padding + 150, y: feeTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(feeInfoLabel)
        feeUnderline.frame = CGRect(x: padding, y: feeTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        feeUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
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
        marginUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedConfirmationButton(_ sender: Any) {
        print("pressedConfirmationButton")
        self.verifyInfo = PlaceOrderDataManager.shared.verify(order: order!)
        self.handleVerifyInfo()
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
                submitOrder()
            }
        } else {
            pushController(orderHash: nil)
        }
    }
    
    func pushController(orderHash: String?) {
        let viewController = ConfirmationResultViewController()
        viewController.order = self.order
        viewController.orderHash = orderHash
        viewController.verifyInfo = self.verifyInfo
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
    
    func submitOrder() {
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
        submitOrder()
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
