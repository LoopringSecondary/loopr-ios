//
//  SettingPartnerViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/18.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import Social

class SettingPartnerViewController: UIViewController {
    
    @IBOutlet weak var spreadingImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    var qrcodeImageView: UIImageView = UIImageView()
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    var sharedImage: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Partner_Title", comment: "")
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        sloganLabel.textColor = .success
        sloganLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        sloganLabel.text = LocalizedString("Partner_Slogan", comment: "")
        
        descriptionLabel.setTitleCharFont()
        descriptionLabel.text = LocalizedString("Partner_Des", comment: "")
        
        walletAddressLabel.setTitleCharFont()
        let addressTip = LocalizedString("Partner_Address", comment: "")
        walletAddressLabel.text = "\(addressTip) \(CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address)"
        
        generateQRCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedShareButton(_ sender: UIButton) {
        let text = LocalizedString("Partner Download Link", comment: "")
        let image = UIImage(named: "Partner-background")
        let overlayingImage = image?.imageOverlayingImages([qrcodeImage], scalingBy: [1])
        let png = UIImagePNGRepresentation(overlayingImage!)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.message, .mail, .airDrop]
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func generateQRCode() {
        let url = PartnerDataManager.shared.generateUrl()
        let data = url.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)!
        let ciContext = CIContext()
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            qrcodeImageCIImage = upScaledImage!
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            qrcodeImage = UIImage(cgImage: cgImage!)
        }
        
        qrcodeImageView.image = qrcodeImage
        spreadingImageView.addSubview(qrcodeImageView)
        let ratio: CGFloat = 750.0/178.0
        qrcodeImageView.frame = CGRect(x: 225/ratio, y: 8828/ratio, width: 300/ratio, height: 300/ratio)
        
        spreadingImageView.contentMode = .top
        spreadingImageView.clipsToBounds = true
        let image = UIImage(named: "Partner-background")
        let overlayingImage = image?.imageOverlayingImages([qrcodeImage], scalingBy: [1])
        spreadingImageView.image = resizeImage(overlayingImage, newWidth: spreadingImageView.frame.width)
    }
    
    // TODO: We need to have another image. One is for displaying in iOS app. The other is for sharing to wechat.
    func resizeImage(_ image: UIImage?, newWidth: CGFloat) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
