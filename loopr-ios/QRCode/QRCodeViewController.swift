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

class QRCodeViewController: UIViewController {
    
    var navigationTitle = LocalizedString("Receive Code", comment: "")
    
    // Set a default value
    var address: String = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
    
    @IBOutlet weak var receiveQRCodeIconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var saveToAlbumButton: UIButton!
    
    @IBOutlet weak var shareContentView: UIView!
    @IBOutlet weak var qrcodeInShare: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var addressInShare: UILabel!
    
    var qrcodeImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = navigationTitle
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        contentView.layer.cornerRadius = 6
        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        contentView.applyShadow()
        
        receiveQRCodeIconView.image = UIImage(named: "Receive-qrcode-icon" + ColorTheme.getTheme())
        titleLabel.setTitleCharFont()
        addressLabel.setTitleCharFont()
        addressInShare.font = FontConfigManager.shared.getCharactorFont(size: 14)
        addressInShare.theme_textColor = GlobalPicker.contrastTextColor
        
        copyAddressButton.setTitle(LocalizedString("Copy Address", comment: ""), for: .normal)
        copyAddressButton.setupSecondary(height: 44)
        
        saveToAlbumButton.setTitle(LocalizedString("Save to Album", comment: ""), for: .normal)
        saveToAlbumButton.setupSecondary(height: 44)
        
        setupShareButton()
        setBackButton()
        
        addressLabel.text = address
        addressInShare.text = address
        
        shareImageView.image = UIImage(named: "Share-wallet\(ColorTheme.getTheme())")
        
        let data = address.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        generateQRCode(from: data!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupShareButton() {
        let shareButton = UIButton(type: UIButtonType.custom)
        shareButton.setImage(UIImage(named: "ShareButtonImage"), for: .normal)
        shareButton.setImage(UIImage(named: "ShareButtonImage")?.alpha(0.3), for: .highlighted)
        shareButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.addTarget(self, action: #selector(pressedShareButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        shareButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItem = shareBarButton
        // Add swipe to go-back feature back which is a system default gesture
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrcodeImageView.image = qrcodeImage
        qrcodeInShare.image = qrcodeImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubview(toFront: receiveQRCodeIconView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func generateQRCode(from data: Data) {
        let ciContext = CIContext()
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            qrcodeImage = UIImage(cgImage: cgImage!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func pressedShareButton(_ button: UIBarButtonItem) {
        let text = LocalizedString("My wallet address in Loopr", comment: "")
        let image = UIImage.imageWithView(shareContentView)
        let png = UIImagePNGRepresentation(image)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.message, .mail]
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func pressedCopyAddressButton(_ sender: Any) {
        print("pressedCopyAddressButton address: \(address)")
        UIPasteboard.general.string = address
        let banner = NotificationBanner.generate(title: "Copy address to clipboard successfully!", style: .success)
        banner.duration = 1
        banner.show()
    }

    @IBAction func pressedSaveToAlbum(_ sender: Any) {
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        print("pressedSaveToAlbum address: \(address)")
        copyAddressButton.isHidden = true
        saveToAlbumButton.isHidden = true
        let image = UIImage.imageWithView(view)
        copyAddressButton.isHidden = false
        saveToAlbumButton.isHidden = false
        QRCodeSaveToAlbum.shared.save(image: image)
    }

}
