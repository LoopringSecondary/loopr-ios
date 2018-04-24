//
//  QRCodeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/25/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Social

class QRCodeViewController: UIViewController {
    
    @IBOutlet weak var qrcodeImageView: UIImageView!
    var qrcodeImage: CIImage!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var saveToAlbumButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("QR Code", comment: "")
        
        view.theme_backgroundColor = GlobalPicker.textColor
        contentView.layer.cornerRadius = 16
        addressLabel.theme_textColor = GlobalPicker.textColor
        addressLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 20)
        copyAddressButton.setTitle(NSLocalizedString("Copy Wallet Address", comment: ""), for: .normal)
        copyAddressButton.backgroundColor = UIColor.clear
        copyAddressButton.titleColor = UIColor.black
        copyAddressButton.layer.cornerRadius = 23
        copyAddressButton.layer.borderWidth = 0.5
        copyAddressButton.layer.borderColor = UIColor.black.cgColor
        copyAddressButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        saveToAlbumButton.setTitle(NSLocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.backgroundColor = UIColor.black
        saveToAlbumButton.layer.cornerRadius = 23
        saveToAlbumButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        setupShareButton()
        setBackButton(image: "Back-button-white")
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address
        addressLabel.text = address
        let data = address?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter!.outputImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupShareButton() {
        let shareButton = UIButton(type: UIButtonType.custom)
        shareButton.setImage(UIImage(named: "ShareButtonImage"), for: .normal)
        shareButton.setImage(UIImage(named: "ShareButtonImage")?.alpha(0.3), for: .highlighted)
        // Default left padding is 20. It should be 12 in our design.
        shareButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.addTarget(self, action: #selector(pressedShareButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        shareButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItem = shareBarButton
        // Add swipe to go-back feature back which is a system default gesture
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
        
        // Remove the blur effect
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        updateNavigationView(tintColor: UIColor.black, textColor: UIColor.white, statusBarStyle: .lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateNavigationView(tintColor: UIColor.white, textColor: UIColor.black, statusBarStyle: .default)
    }
    
    @IBAction func pressedShareButton(_ button: UIBarButtonItem) {
        let objectsToShare: [Any] = ["textToShare", UIImage(ciImage: qrcodeImage)]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func pressedCopyAddressButton(_ sender: Any) {
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        print("pressedCopyAddressButton address: \(address)")
        UIPasteboard.general.string = address
    }

    @IBAction func pressedSaveToAlbum(_ sender: Any) {
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        print("pressedSaveToAlbum address: \(address)")
    }

}
