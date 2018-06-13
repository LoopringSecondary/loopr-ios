//
//  DisplayKeystoreInQRCodeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class DisplayKeystoreInQRCodeViewController: UIViewController {

    var keystore: String = ""
    
    @IBOutlet weak var qrcodeImageView: UIImageView!
    var qrcodeImage: CIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let data = keystore.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter!.outputImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove the blur effect
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
    }

}
