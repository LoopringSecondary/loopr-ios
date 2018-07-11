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
    
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareOrderButton: UIButton!
    @IBOutlet weak var saveToAlbumButton: UIButton!
    
    var qrcodeImage: UIImage!
    var order: OriginalOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Order QR Code", comment: "")
        view.theme_backgroundColor = GlobalPicker.textColor
        contentView.layer.cornerRadius = 16
        setBackButton(image: "Back-button-white")
        saveToAlbumButton.setTitle(LocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.setupRoundBlack()
        shareOrderButton.setTitle(LocalizedString("Share the Order", comment: ""), for: .normal)
        shareOrderButton.setupRoundBlack()
        generateQRCode(order: self.order!)
    }
    
    func generateQRCode(order: OriginalOrder) {
        if let privateKey = getOrderDataFromLocal(order: order) {
            let hash = order.hash + TradeDataManager.seperator
            var data = hash.data(using: .isoLatin1, allowLossyConversion: false)!
            let authPrivateKey = privateKey.data(using: .isoLatin1, allowLossyConversion: false)!
            data.append(authPrivateKey)
            let ciContext = CIContext()
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 2, y: 2)
                let upScaledImage = filter.outputImage?.transformed(by: transform)
                let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                qrcodeImage = UIImage(cgImage: cgImage!)
            }
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
    
    func updateNavigationView(tintColor: UIColor, textColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        self.navigationController?.navigationBar.barTintColor = tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        self.navigationController?.navigationBar.tintColor = textColor
        
        // Update the statusBar
        UIApplication.shared.statusBarStyle = statusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrcodeImageView.image = qrcodeImage
        updateNavigationView(tintColor: UIColor.black, textColor: UIColor.white, statusBarStyle: .lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateNavigationView(tintColor: UIColor.white, textColor: UIColor.black, statusBarStyle: .default)
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
