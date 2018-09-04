//
//  QRCodeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/25/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Social
import NotificationBannerSwift

class OrderQRCodeViewController: UIViewController {

    @IBOutlet weak var qrcodeIconImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var saveToAlbumButton: UIButton!
    @IBOutlet weak var shareOrderButton: UIButton!
    
    @IBOutlet weak var shareContentView: UIView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var titleInShare: UILabel!
    @IBOutlet weak var qrcodeInShare: UIImageView!
    @IBOutlet weak var sellTipLabel: UILabel!
    @IBOutlet weak var sellInfoLabel: UILabel!
    @IBOutlet weak var buyTipLabel: UILabel!
    @IBOutlet weak var buyInfoLabel: UILabel!
    @IBOutlet weak var priceBuyLabel: UILabel!
    @IBOutlet weak var priceSellLabel: UILabel!
    @IBOutlet weak var unitBuyLabel: UILabel!
    @IBOutlet weak var unitSellLabel: UILabel!
    @IBOutlet weak var buyEqualLabel: UILabel!
    @IBOutlet weak var sellEqualLabel: UILabel!
    @IBOutlet weak var validTipInShare: UILabel!
    @IBOutlet weak var validInShare: UILabel!
    @IBOutlet weak var loopringTipLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var originalOrder: OriginalOrder?
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    var dismissClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Loopring P2P Order", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        // TokenView
        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        qrcodeIconImageView.image = UIImage(named: "Order-qrcode-icon" + ColorTheme.getTheme())

        saveToAlbumButton.setTitle(LocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.setupPrimary(height: 44)
        shareOrderButton.setTitle(LocalizedString("Share Order", comment: ""), for: .normal)
        shareOrderButton.setupSecondary(height: 44)
        generateQRCode(originalOrder: self.originalOrder!)
        
        if let order = self.originalOrder {
            setupShareView(order: order)
        }
    }
    
    func setupShareView(order: OriginalOrder) {
        shareImageView.image = UIImage(named: "Share-order")
        logoImageView.image = UIImage(named: "\(Production.getProduct())_share_logo")
        
        titleInShare.font = FontConfigManager.shared.getCharactorFont(size: 20)
        titleInShare.theme_textColor = GlobalPicker.contrastTextColor
        titleInShare.text = LocalizedString("Loopring Order", comment: "")
        
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
        
        unitBuyLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        unitBuyLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        unitBuyLabel.text = "1 \(order.tokenSell)"
        
        priceBuyLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        priceBuyLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        priceBuyLabel.text = "\(price.withCommas()) \(order.tokenBuy)"
        
        unitSellLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        unitSellLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        unitSellLabel.text = "1 \(order.tokenBuy)"
        
        priceSellLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        priceSellLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        priceSellLabel.text = "\((1/price).withCommas()) \(order.tokenSell)"
        
        buyEqualLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        buyEqualLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        sellEqualLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        sellEqualLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        
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
    
    func generateQRCode(originalOrder: OriginalOrder) {
        guard let data = P2POrderHistoryDataManager.shared.getOrderDataFromLocal(originalOrder: originalOrder) else { return }
        var body = JSON()
        let array = data.components(separatedBy: "-")
        body["type"] = JSON(TradeDataManager.qrcodeType)
        body["value"] = [TradeDataManager.qrcodeHash: originalOrder.hash,
                         TradeDataManager.qrcodeAuth: array[0],
                         TradeDataManager.sellRatio: array[1]]
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let originalOrder = self.originalOrder, let image = self.qrcodeImageCIImage else { return }
        
        generateQRCode(originalOrder: originalOrder)
        qrcodeImageView.image = qrcodeImage
        let scaleX = qrcodeImageView.frame.size.width / image.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / image.extent.size.height
        let transformedImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        qrcodeInShare.image = UIImage.init(ciImage: transformedImage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func close() {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        close()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        if contentView.frame.contains(location) {
            return false
        }
        return true
    }
    
    @IBAction func pressedShareButton(_ sender: UIButton) {
        let text = LocalizedString("My Order QR code in Loopr-iOS", comment: "")
        let image = UIImage.imageWithView(shareContentView)
        let png = UIImagePNGRepresentation(image)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func pressedSaveToAlbum(_ sender: Any) {
        let image = UIImage.imageWithView(shareContentView)
        QRCodeSaveToAlbum.shared.save(image: image)
    }
}
