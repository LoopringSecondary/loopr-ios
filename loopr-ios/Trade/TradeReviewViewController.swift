//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeReviewViewController: UIViewController {
    
    @IBOutlet weak var tokenS: UIView!
    @IBOutlet weak var tokenB: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var validTipLabel: UILabel!
    @IBOutlet weak var validInfoLabel: UILabel!
    
    @IBOutlet weak var shareContentView: UIView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrcodeInShare: UIImageView!
    @IBOutlet weak var sellTipLabel: UILabel!
    @IBOutlet weak var sellInfoLabel: UILabel!
    @IBOutlet weak var buyTipLabel: UILabel!
    @IBOutlet weak var buyInfoLabel: UILabel!
    @IBOutlet weak var priceBuyLabel: UILabel!
    @IBOutlet weak var priceSellLabel: UILabel!
    @IBOutlet weak var validTipInShare: UILabel!
    @IBOutlet weak var validInShare: UILabel!
    @IBOutlet weak var loopringTipLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var tokenSView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBView: TradeViewOnlyViewController = TradeViewOnlyViewController()

    // To display QR code
    var qrcodeImageCIImage: CIImage!
    var qrcodeImage: UIImage!

    var order: OriginalOrder?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        setupShareButton()
        self.view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Order Detail", comment: "")
        
        // TokenView
        tokenSView.view.frame = CGRect(x: 0, y: 0, width: tokenS.frame.width, height: tokenS.frame.height)
        tokenS.addSubview(tokenSView.view)
        tokenSView.view.bindFrameToAnotherView(anotherView: tokenS)
        
        tokenBView.view.frame = CGRect(x: 0, y: 0, width: tokenB.frame.width, height: tokenB.frame.height)
        tokenB.addSubview(tokenBView.view)
        tokenBView.view.bindFrameToAnotherView(anotherView: tokenB)
        
        // Labels
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.setTitleDigitFont()
        
        validTipLabel.setTitleCharFont()
        validTipLabel.text = LocalizedString("Time to Live", comment: "")
        validInfoLabel.setTitleDigitFont()
        
        if let order = self.order {
            setupShareView(order: order)
        }
        
        // Receive order response
        NotificationCenter.default.addObserver(self, selector: #selector(orderResponseReceivedNotification), name: .orderResponseReceived, object: nil)
    }
    
    func setupShareView(order: OriginalOrder) {
        shareImageView.image = UIImage(named: "Share-order")
        logoImageView.image = UIImage(named: "\(Production.getProduct())_share_logo")
        
        titleLabel.font = FontConfigManager.shared.getCharactorFont(size: 20)
        titleLabel.theme_textColor = GlobalPicker.contrastTextColor
        titleLabel.text = LocalizedString("Loopring Order", comment: "")
        
        sellTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        sellTipLabel.theme_textColor = GlobalPicker.contrastTextColor
        sellTipLabel.text = LocalizedString("Sell", comment: "")
        var length = Asset.getLength(of: order.tokenSell) ?? 4
        sellInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        sellInfoLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        sellInfoLabel.text = order.amountSell.withCommas(length)  + " " + order.tokenSell
        
        buyTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        buyTipLabel.theme_textColor = GlobalPicker.contrastTextColor
        buyTipLabel.text = LocalizedString("Buy", comment: "")
        length = Asset.getLength(of: order.tokenBuy) ?? 4
        buyInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        buyInfoLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        buyInfoLabel.text = order.amountBuy.withCommas(length) + " " + order.tokenBuy
       
        let price = order.amountBuy / order.amountSell
        priceBuyLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        priceBuyLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        priceBuyLabel.textAlignment = .justified
        priceBuyLabel.text = "1 \(order.tokenSell) = \(price.withCommas()) \(order.tokenBuy)"
        priceSellLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        priceSellLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        priceSellLabel.text = "1 \(order.tokenBuy) = \((1/price).withCommas()) \(order.tokenSell)"
        priceSellLabel.textAlignment = .justified
        
        validTipInShare.font = FontConfigManager.shared.getCharactorFont(size: 12)
        validTipInShare.theme_textColor = GlobalPicker.contrastTextColor
        validTipInShare.text = LocalizedString("Time to Live", comment: "")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validInShare.font = FontConfigManager.shared.getCharactorFont(size: 12)
        validInShare.theme_textColor = GlobalPicker.contrastTextDarkColor
        validInShare.text = until
        
        loopringTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        loopringTipLabel.theme_textColor = GlobalPicker.contrastTextLightColor
        loopringTipLabel.text = LocalizedString("Loopring_TIP", comment: "")
        
        productLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        productLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        productLabel.text = Production.getProduct()
        
        urlLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        urlLabel.theme_textColor = GlobalPicker.contrastTextColor
        urlLabel.text = Production.getUrlText()
    }

    @objc func orderResponseReceivedNotification() {
        let vc = TradeCompleteViewController()
        vc.order = self.order
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let order = self.order else { return }
        
        tokenSView.update(type: .sell, symbol: order.tokenSell, amount: order.amountSell)
        tokenBView.update(type: .buy, symbol: order.tokenBuy, amount: order.amountBuy)
        
        generateQRCode(order: order)
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImageCIImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImageCIImage.extent.size.height
        let transformedImage = qrcodeImageCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        qrcodeInShare.image = UIImage.init(ciImage: transformedImage)
        
        statusInfoLabel.textColor = .success
        statusInfoLabel.text = LocalizedString("Open", comment: "")
        let since = DateUtil.convertToDate(UInt(order.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validInfoLabel.text = "\(since) ~ \(until)"
    }
    
    func setupShareButton() {
        let shareButton = UIButton(type: UIButtonType.custom)
        shareButton.setImage(UIImage(named: "ShareButtonImage"), for: .normal)
        shareButton.setImage(UIImage(named: "ShareButtonImage")?.alpha(0.3), for: .highlighted)
        shareButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.addTarget(self, action: #selector(pressedShareButton(_:)), for: UIControlEvents.touchUpInside)
        shareButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItem = shareBarButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func generateQRCode(order: OriginalOrder) {
        var body = JSON()
        body["type"] = JSON(TradeDataManager.qrcodeType)
        body["value"] = [TradeDataManager.qrcodeHash: order.hash,
                         TradeDataManager.qrcodeAuth: order.authPrivateKey,
                         TradeDataManager.sellRatio: TradeDataManager.shared.sellRatio]
        do {
            let data = try body.rawData(options: .prettyPrinted)
            let ciContext = CIContext()
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let upScaledImage = filter.outputImage?.transformed(by: transform)
                qrcodeImageCIImage = upScaledImage!
                let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                qrcodeImage = UIImage(cgImage: cgImage!)
            }
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }

    @IBAction func pressedShareButton(_ sender: UIButton) {
        let text = LocalizedString("My Trade QRCode", comment: "")
        let image = UIImage.imageWithView(shareContentView)
        let png = UIImagePNGRepresentation(image)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
