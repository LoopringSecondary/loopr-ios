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
    
    var originalOrder: OriginalOrder?
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    var dismissClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Loopr P2P Order", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)

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
        generateQRCode(originalOrder: originalOrder)
        qrcodeImageView.image = qrcodeImage
        let scaleX = qrcodeImageView.frame.size.width / image.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / image.extent.size.height
        let transformedImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
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
        let png = UIImagePNGRepresentation(qrcodeImage)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func pressedSaveToAlbum(_ sender: Any) {
        QRCodeSaveToAlbum.shared.save(image: qrcodeImage)
    }
}
