//
//  DisplayContractVersionViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class DisplayContractVersionViewController: UIViewController {

    @IBOutlet weak var contractVersionLabel: UILabel!
    @IBOutlet weak var contractVersionTextView: UITextView!

    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Contract Version", comment: "")
        view.theme_backgroundColor = ColorPicker.backgroundColor
        contractVersionTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        contractVersionTextView.cornerRadius = 6
        contractVersionTextView.font = UIFont(name: "Menlo", size: 14)
        contractVersionTextView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        contractVersionTextView.theme_textColor = GlobalPicker.textLightColor
        contractVersionTextView.isEditable = false

        contractVersionLabel.font = UIFont(name: "Menlo", size: 14)
        contractVersionLabel.theme_textColor = GlobalPicker.textLightColor
        contractVersionLabel.text = RelayAPIConfiguration.protocolAddress
        url = URL(string: "https://etherscan.io/address/\(RelayAPIConfiguration.protocolAddress)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if url != nil {
            setupSafariButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func setupSafariButton() {
        let safariButton = UIButton(type: UIButtonType.custom)
        safariButton.setImage(UIImage(named: "Safari-item-button"), for: .normal)
        safariButton.setImage(UIImage(named: "Safari-item-button")?.alpha(0.3), for: .highlighted)
        safariButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        safariButton.addTarget(self, action: #selector(pressedSafariButton(_:)), for: UIControlEvents.touchUpInside)
        // The size of the image.
        safariButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: safariButton)
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc func pressedSafariButton(_ button: UIBarButtonItem) {
        if let url = self.url {
            UIApplication.shared.open(url)
        }
    }

}
