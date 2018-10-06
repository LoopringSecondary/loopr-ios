//
//  SettingPartnerViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Social
import Crashlytics

class SettingPartnerViewController: UIViewController {

    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    var qrcodeImageView: UIImageView = UIImageView(frame: .zero)
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    var sharedImage: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Partner_Title", comment: "")
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        sloganLabel.textColor = .success
        sloganLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        sloganLabel.text = LocalizedString("Partner_Des", comment: "")
        sloganLabel.numberOfLines = 0
        
        walletAddressLabel.setSubTitleDigitFont()
        let addressTip = LocalizedString("Partner_Address", comment: "")
        walletAddressLabel.text = "\(addressTip)\n\(CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address)"
        walletAddressLabel.numberOfLines = 2
        walletAddressLabel.lineBreakMode = .byTruncatingMiddle
        
        shareButton.setupSecondary(height: 44)
        shareButton.setTitle(LocalizedString("Share App", comment: ""), for: .normal)
        shareButton.addTarget(self, action: #selector(pressedShareButton), for: .touchUpInside)
        
        generateQRCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func openShare() {
        let text = LocalizedString("Partner Download Link", comment: "")
        
        var image: UIImage?
        if ColorTheme.getCurrent() == .green {
            image = UIImage(named: "Partner-background\(ColorTheme.getTheme())")
        } else if ColorTheme.getCurrent() == .yellow {
            image = UIImage(named: "Partner-background\(ColorTheme.getTheme())-\(SettingDataManager.shared.getCurrentLanguage().name)")
        }
        
        if image != nil {
            let overlayingImage = imageOverlayingImages(parentImage: image!, childImages: [qrcodeImage], scalingBy: [1])
            let png = UIImagePNGRepresentation(overlayingImage)
            let shareAll = [text, png!] as [Any]
            let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityVC.excludedActivityTypes = [.message, .mail, .airDrop]
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.completionWithItemsHandler = {(activity, success, items, error) in
                print(activity.debugDescription)
                if success && activity != nil {
                    Answers.logShare(withMethod: "System default share", contentName: "City Partner", contentType: activity!.rawValue as String, contentId: nil, customAttributes: nil)
                }
            }
            self.present(activityVC, animated: true, completion: nil)
        }
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
    }
    
    func imageOverlayingImages(parentImage: UIImage, childImages: [UIImage], scalingBy factors: [CGFloat]? = nil) -> UIImage {
        let size = parentImage.size
        let container = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        
        parentImage.draw(in: container)
        
        let scaleFactors = factors ?? [CGFloat](repeating: 1.0, count: childImages.count)
        
        // Need to keep the bottom distance consistent. 
        for (image, scaleFactor) in zip(childImages, scaleFactors) {
            let topWidth: CGFloat = 151
            let topHeight: CGFloat = 151
            let topX: CGFloat = 112
            let topY: CGFloat = size.height - 151 - 209 // 4054
            
            image.draw(in: CGRect(x: topX, y: topY, width: topWidth, height: topHeight), blendMode: .normal, alpha: 1.0)
        }
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    @objc func pressedShareButton(_ sender: Any) {
        openShare()
    }

}
