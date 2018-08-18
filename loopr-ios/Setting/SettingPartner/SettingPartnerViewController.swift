//
//  SettingPartnerViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/18.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SettingPartnerViewController: UIViewController {
    
    @IBOutlet weak var spreadingImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    var qrcodeImage: UIImage!
    var qrcodeImageCIImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Partner_Title", comment: "")
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        sloganLabel.textColor = .success
        sloganLabel.font = FontConfigManager.shared.getCharactorFont(size: 20)
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
        let text = LocalizedString("My wallet address in Loopr", comment: "")
        let shareAll = [text] as [Any]
        
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
}
