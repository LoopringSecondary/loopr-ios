//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import SVProgressHUD
import NotificationBannerSwift

class TradeReviewViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()

    var qrcodeImageView: UIImageView!
    var qrcodeImage: CIImage!

    // TODO: put the following UILabel and UIView to a UIView?
    var marginSplitLabel: UILabel = UILabel()
    var marginSplitValueLabel: UILabel = UILabel()

    var LRCFeeLabel: UILabel = UILabel()
    var LRCFeeValueLabel: UILabel = UILabel()
    var LRCFeeUnderLine: UIView = UIView()

    var priceLabel: UILabel = UILabel()
    var priceValueLabel: UILabel = UILabel()
    var priceUnderLine: UIView = UIView()
    
    var verifyInfo: [String: Double]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        
        // TODO: Review or Confirmation?
        self.navigationItem.title = NSLocalizedString("Order Details", comment: "")
        
        placeOrderButton.title = NSLocalizedString("Share Order", comment: "")
        placeOrderButton.setupRoundBlack()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let paddingY: CGFloat = 20
        let paddingLeft: CGFloat = 15
        let paddingTop: CGFloat = 30
        let padding: CGFloat = 15
        let rowHeight: CGFloat = 40
        let rowPadding: CGFloat = 10

        // QR code
        let qrCodeWidth: CGFloat = screenWidth*0.53*UIStyleConfig.scale
        qrcodeImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: paddingTop + qrCodeWidth*0.5), size: CGSize(width: qrCodeWidth, height: qrCodeWidth)))
        scrollView.addSubview(qrcodeImageView)
        
        let data = "hello world".data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter!.outputImage

        let tokenViewMinY: CGFloat = qrcodeImageView.frame.maxY + paddingY
        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: tokenViewMinY, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenSView)
        
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: tokenViewMinY, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenBView)
        
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32*UIStyleConfig.scale, height: 32*UIStyleConfig.scale)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        scrollView.addSubview(arrowRightImageView)
        
        // Price label
        priceLabel.text = NSLocalizedString("Price", comment: "")
        priceLabel.textColor = UIColor.black
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        priceLabel.frame = CGRect(x: paddingLeft, y: tokenSView.frame.maxY + paddingY, width: 160, height: rowHeight)
        scrollView.addSubview(priceLabel)
        
        priceValueLabel.textColor = UIColor.black
        priceValueLabel.textAlignment = .right
        priceValueLabel.font = FontConfigManager.shared.getLabelFont()
        priceValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 200, y: priceLabel.frame.minY, width: 200, height: rowHeight)
        scrollView.addSubview(priceValueLabel)
        
        priceUnderLine.frame = CGRect(x: paddingLeft, y: priceLabel.frame.maxY - 5, width: screenWidth - paddingLeft * 2, height: 1)
        priceUnderLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        scrollView.addSubview(priceUnderLine)
        
        // Trading Fee
        LRCFeeLabel.text = NSLocalizedString("Trading Fee", comment: "")
        LRCFeeLabel.textColor = UIColor.black
        LRCFeeLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeLabel.frame = CGRect(x: paddingLeft, y: priceValueLabel.frame.maxY + rowPadding, width: 160, height: rowHeight)
        scrollView.addSubview(LRCFeeLabel)
        
        LRCFeeValueLabel.textColor = UIColor.black
        LRCFeeValueLabel.textAlignment = .right
        LRCFeeValueLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 160, y: LRCFeeLabel.frame.minY, width: 160, height: rowHeight)
        scrollView.addSubview(LRCFeeValueLabel)
        
        LRCFeeUnderLine.frame = CGRect(x: paddingLeft, y: LRCFeeLabel.frame.maxY - 5, width: screenWidth - paddingLeft * 2, height: 1)
        LRCFeeUnderLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        scrollView.addSubview(LRCFeeUnderLine)
        
        // Margin Split
        marginSplitLabel.text = NSLocalizedString("Margin Split", comment: "")
        marginSplitLabel.textColor = UIColor.black
        marginSplitLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitLabel.frame = CGRect(x: paddingLeft, y: LRCFeeLabel.frame.maxY + rowPadding, width: 160, height: rowHeight)
        scrollView.addSubview(marginSplitLabel)

        marginSplitValueLabel.text = SettingDataManager.shared.getMarginSplitDescription()
        marginSplitValueLabel.textColor = UIColor.black
        marginSplitValueLabel.textAlignment = .right
        marginSplitValueLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 160, y: marginSplitLabel.frame.minY, width: 160, height: rowHeight)
        scrollView.addSubview(marginSplitValueLabel)

        scrollView.contentSize = CGSize(width: screenWidth, height: marginSplitLabel.frame.maxY + padding)
        
        // TODO: Use mock data for now.
        LRCFeeValueLabel.text = "2 LRC"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.isNavigationBarHidden = false

        tokenSView.update(title: "You send", symbol: TradeDataManager.shared.tokenS.symbol, amount: TradeDataManager.shared.amountTokenS)
        tokenBView.update(title: "You get", symbol: TradeDataManager.shared.tokenB.symbol, amount: TradeDataManager.shared.amountTokenB)
        
        // TODO: the precision should be dynamic
        let price: String = String(format: "%.6f", TradeDataManager.shared.amountTokenS / TradeDataManager.shared.amountTokenB)
        priceValueLabel.text = "\(price) \(TradeDataManager.shared.tokenS.symbol)/\(TradeDataManager.shared.tokenB.symbol)"
        
        // Remove the blur effect
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
//        self.verifyInfo = TradeDataManager.shared.verify(order: <#T##OriginalOrder#>, isTaker: true) TODO
        self.handleVerifyInfo()
    }

}

extension TradeReviewViewController {
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
                submitRing()
            }
        } else {
            pushController(orderHash: nil)
        }
    }
    
    func pushController(orderHash: String?) {
        let viewController = ConfirmationResultViewController()
//        viewController.order = self.order   TODO
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
    
    func submitRing() {
        // TODO: call _submitRing
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
        submitRing()
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
