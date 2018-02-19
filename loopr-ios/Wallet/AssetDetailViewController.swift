//
//  AssetDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetDetailViewController: UIViewController {

    var asset: Asset? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = asset?.symbol

        // For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        
        // We need to reduce the spacing between two UIBarButtonItems
        let sendButton = UIButton(type: UIButtonType.custom)
        sendButton.setImage(UIImage.init(named: "Send"), for: UIControlState.normal)
        sendButton.setImage(UIImage.init(named: "Send-highlight"), for: UIControlState.highlighted)
        sendButton.addTarget(self, action: #selector(self.pressSendButton(_:)), for: UIControlEvents.touchUpInside)
        sendButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let sendBarButton = UIBarButtonItem(customView: sendButton)

        let qrCodebutton = UIButton(type: UIButtonType.custom)
        qrCodebutton.setImage(UIImage.init(named: "QRCode"), for: UIControlState.normal)
        
        // TODO: add a QRCode-highlight icon
        
        qrCodebutton.addTarget(self, action: #selector(self.pressSendButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)

        self.navigationItem.rightBarButtonItems = [sendBarButton, qrCodeBarButton]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
    }
    
    @objc func pressSendButton(_ button: UIBarButtonItem) {
        print("pressSendButton")
    }

}
