//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeReviewViewController: UIViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var tokenS: UIView!
    @IBOutlet weak var tokenB: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var validTipLabel: UILabel!
    @IBOutlet weak var validInfoLabel: UILabel!
    
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
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
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
        
        // Receive order response
        NotificationCenter.default.addObserver(self, selector: #selector(orderResponseReceivedNotification), name: .orderResponseReceived, object: nil)
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
        qrcodeImageView.image = qrcodeImage
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImageCIImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImageCIImage.extent.size.height
        let transformedImage = qrcodeImageCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        
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
        let text = LocalizedString("My Trade from Loopr-iOS", comment: "")
        let png = UIImagePNGRepresentation(qrcodeImage)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
