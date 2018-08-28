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
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleInShare: UILabel!
    @IBOutlet weak var tokenSInShare: UIView!
    @IBOutlet weak var tokenBInShare: UIView!
    @IBOutlet weak var qrcodeInShare: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var validTipInShare: UILabel!
    @IBOutlet weak var validInShare: UILabel!
    
    var tokenSViewInShare: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBViewInShare: TradeViewOnlyViewController = TradeViewOnlyViewController()
    
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
        tokenSViewInShare.view.frame = CGRect(x: 0, y: 0, width: tokenSInShare.frame.width, height: tokenSInShare.frame.height)
        tokenSInShare.addSubview(tokenSViewInShare.view)
        tokenSViewInShare.view.bindFrameToAnotherView(anotherView: tokenSInShare)
        
        tokenBViewInShare.view.frame = CGRect(x: 0, y: 0, width: tokenBInShare.frame.width, height: tokenBInShare.frame.height)
        tokenBInShare.addSubview(tokenBViewInShare.view)
        tokenBViewInShare.view.bindFrameToAnotherView(anotherView: tokenBInShare)

        shareContentView.theme_backgroundColor = ColorPicker.backgroundColor
        logoImageView.image = UIImage(named: "\(Production.getProduct())_share_logo")
        titleInShare.setTitleCharFont()
        titleInShare.text = Production.getProduct()
        validTipInShare.font = FontConfigManager.shared.getCharactorFont(size: 14)
        validTipInShare.theme_textColor = GlobalPicker.contrastTextLightColor
        validTipInShare.text = "订单有效期"
        validInShare.font = FontConfigManager.shared.getCharactorFont(size: 14)
        validInShare.theme_textColor = GlobalPicker.contrastTextColor
        shareImageView.image = UIImage(named: "Share-order")
        
        qrcodeIconImageView.image = UIImage(named: "Order-qrcode-icon" + ColorTheme.getTheme())

        saveToAlbumButton.setTitle(LocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.setupPrimary(height: 44)
        shareOrderButton.setTitle(LocalizedString("Share Order", comment: ""), for: .normal)
        shareOrderButton.setupSecondary(height: 44)
        generateQRCode(originalOrder: self.originalOrder!)
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
        
        tokenSViewInShare.update(type: .sell, symbol: originalOrder.tokenSell, amount: originalOrder.amountSell)
        tokenBViewInShare.update(type: .buy, symbol: originalOrder.tokenBuy, amount: originalOrder.amountBuy)
        
        generateQRCode(originalOrder: originalOrder)
        qrcodeImageView.image = qrcodeImage
        let scaleX = qrcodeImageView.frame.size.width / image.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / image.extent.size.height
        let transformedImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        qrcodeInShare.image = UIImage.init(ciImage: transformedImage)
        
        let since = DateUtil.convertToDate(UInt(originalOrder.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(originalOrder.validUntil), format: "MM-dd HH:mm")
        validInShare.text = "\(since) ~ \(until)"
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
