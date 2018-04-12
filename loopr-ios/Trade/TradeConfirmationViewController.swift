//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeConfirmationViewController: UIViewController {
    
    var qrcodeImageView: UIImageView!
    var qrcodeImage: CIImage!
    
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()
    
    @IBOutlet weak var shareOrderButton: UIButton!
    @IBOutlet weak var closeOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        
        setBackButton()
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        // QR code

        qrcodeImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: screenHeight/5), size: CGSize(width: screenWidth*0.5, height: screenWidth*0.5)))
        view.addSubview(qrcodeImageView)

        let data = "hello world".data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter!.outputImage
        
        // Token View

        let tokenViewMinY: CGFloat = screenHeight/2.5

        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: tokenViewMinY, width: (screenWidth-30)/2, height: 200))
        view.addSubview(tokenSView)
        
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: tokenViewMinY, width: (screenWidth-30)/2, height: 200))
        view.addSubview(tokenBView)
        
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32, height: 32)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        view.addSubview(arrowRightImageView)
        
        // Buttons

        shareOrderButton.setTitle(NSLocalizedString("Share the Order", comment: ""), for: .normal)

        shareOrderButton.backgroundColor = UIColor.clear
        shareOrderButton.titleColor = UIColor.black
        shareOrderButton.layer.cornerRadius = 23
        shareOrderButton.layer.borderWidth = 0.5
        shareOrderButton.layer.borderColor = UIColor.black.cgColor
        shareOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        closeOrderButton.setTitle(NSLocalizedString("Close the Order", comment: ""), for: .normal)

        closeOrderButton.backgroundColor = UIColor.black
        closeOrderButton.layer.cornerRadius = 23
        closeOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tokenSView.update(title: "You send", symbol: TradeDataManager.shared.tokenS.symbol, amount: TradeDataManager.shared.amountTokenS)
        tokenBView.update(title: "You get", symbol: TradeDataManager.shared.tokenB.symbol, amount: TradeDataManager.shared.amountTokenB)
        
        // Remove the blur effect
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
    }
    
    @IBAction func pressedShareOrderButton(_ sender: Any) {
        print("pressedShareOrderButton")
    }

    @IBAction func pressedCloseOrderButton(_ sender: Any) {
        print("pressedCloseOrderButton")
        let viewController = TradeCompleteViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
