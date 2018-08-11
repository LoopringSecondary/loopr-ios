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
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var saveToAlbumButton: UIButton!
    @IBOutlet weak var shareOrderButton: UIButton!
    
    var order: OriginalOrder?
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    var dismissClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Loopr P2P Order", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        saveToAlbumButton.setTitle(LocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.setupPrimary(height: 42)
        shareOrderButton.setTitle(LocalizedString("Share the Order", comment: ""), for: .normal)
        shareOrderButton.setupSecondary(height: 42)
        generateQRCode(order: self.order!)
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
    
    func getOrderDataFromLocal(order: OriginalOrder) -> String? {
        let defaults = UserDefaults.standard
        if let orderData = defaults.dictionary(forKey: UserDefaultsKeys.p2pOrder.rawValue) {
            if let authPrivateKey = orderData[order.hash] as? String {
                return authPrivateKey
            }
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let order = self.order else { return }
        generateQRCode(order: order)
        qrcodeImageView.image = qrcodeImage
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImageCIImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImageCIImage.extent.size.height
        let transformedImage = qrcodeImageCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
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
