//
//  NewSettingPartnerViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Social

class NewSettingPartnerViewController: UIViewController {

    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    var qrcodeImageView: UIImageView = UIImageView()
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
    }
    
    @objc func pressedShareButton(_ sender: Any) {
        openShare()
    }

}
